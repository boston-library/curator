# frozen_string_literal: true

module Curator
  module Serializers
    module SchemaBuilders
      module BuilderHelpers
        class Element
          class Attribute
            attr_reader :name, :target_value, :xml_label

            def initialize(attr_name, xml_label: nil, &block)
              @name = attr_name

              @xml_label = xml_label.present? ? xml_label : attr_name
              @target_value = block if block_given?

              @target_value = attr_name.to_sym if @target_value.blank?
            end
          end

          attr_reader :attributes, :name, :target_value

          # NOTE: target_value can be a string,symbol or lambda for an Element / Node

          def initialize(name, target_val: nil, &block)
            @name = name
            @attributes = []
            instance_exec(&block) if block_given?
            @target_value ||= target_val.present? ? target_val : name.to_sym
          end

          def attribute(attr_name, xml_label: nil, &block)
            attr = block_given? ? Attribute.new(attr_name.to_sym, xml_label: xml_label, &block) : Attribute.new(attr_name, xml_label: xml_label)
            attributes << attr
          end
        end

        class RelationalNode < Element
          attr_reader :elements, :multi_valued, :target_object, :target_value_blank, :xml_label

          # Note target_obj is different than target value.
          def initialize(name, target_obj: nil, multi_valued: false, xml_label: nil, &block)
            @elements = []
            @multi_valued = multi_valued
            @target_object = target_obj.present? ? target_obj : name.to_sym
            @target_value_blank = false
            @xml_label = xml_label
            super(name, &block)
            @target_value = target_value_blank ? nil : @target_value
          end

          def target_value_blank!
            @target_value_blank = true
          end

          def target_value_blank?
            @target_value_blank
          end

          def target_value_as(val = nil, &block)
            @target_value = block if block_given?

            @target_value ||= val
          end

          def element(el_name, target_val: nil, &block)
            el = block_given? ? Element.new(el_name, target_val: target_val, &block) : Element.new(el_name, target_val: target_val)
            elements << el
          end

          def node(node_name, target_obj: nil, multi_valued: false, label: nil ,&block)
            raise ArgumentError, 'No block given in node method' if block.blank?

            elements << self.class.new(node_name, target_obj: target_obj, multi_valued: multi_valued, xml_label: label, &block)
          end
        end

        module XMLBuilder
          extend ActiveSupport::Concern

          SCHEMA_BUILDER_DSL = { _xml_elements: {}, _root_name: nil, _root_namespace: nil, _namespace_separator: ':', _root_attributes: {} , _root_element: nil, _xml_key_transform: :camelize_lower }.freeze
          private_constant :SCHEMA_BUILDER_DSL

          CONDITION_UNMET = Object.new.freeze
          private_constant :CONDITION_UNMET

          included do
            SCHEMA_BUILDER_DSL.each { |name, initial| instance_variable_set("@#{name}", initial.dup) unless instance_variable_defined?("@#{name}") }

            include InstanceMethods
            extend ClassMethods
          end

          module InstanceMethods
            attr_reader :object, :params

            def initialize(object, params: {})
              @object = object
              @params = params.freeze
              @method_existence = {} # Cache for `respond_to?` result
              SCHEMA_BUILDER_DSL.each_key { |name| instance_variable_set("@#{name}", self.class.public_send(name)) }
            end

            def serialize
              return Ox.dump(document, indent: params[:indent]) if params[:indent]

              Ox.dump(document)
            end

            def serializable_document
              document
            end

            def serializable_hash
              doc_enum = serializable_document.each
              doc_enum.reduce({}, &build_hash)
            end

            protected

            def root_element
              return @_root_element if defined?(@_root_element) && !@_root_element.nil?

              @_root_element = Ox::Element.new(fetch_root_element_name)

              root_attributes.each_pair { |attr_name, attr_value| @_root_element[attr_name] = attr_value }

              @_root_element
            end

            def document
              return @document if defined?(@document) && !@document.nil?

              @document = Ox::Document.new(version: '1.0', encoding: 'UTF-8')

              if object_is_collection?
                object.each { |obj| build_elements(root_element, object, xml_elements) }
              else
                build_elements(root_element, object, xml_elements)
              end
              @document << root_element
              @document
            end

            private

            def add_to_root
              lambda do |root, xml_el|
                root << xml_el
              end
            end

            def build_hash
              lambda do |hash, element|
                hash[element.name] ||= []
                element.attributes.each_pair { |k,v| hash[element.name] << {k => v} } if element.attributes.present?
                element.each do |el_value|
                  case el_value
                  when Ox::Element
                    el_hash = build_hash.call(el_value, {})
                    hash[element.name] << el_hash
                  else
                    hash[element.name] << el_value
                  end
                end
                hash
              end
            end

            def build_elements(root, target_object, elements)
              return root if elements.blank?

              elements.each_pair do |element_name, element|
                begin
                  el = case element
                      when Array
                        build_conditional(target_object, element_name, element)
                      when BuilderHelpers::RelationalNode
                        build_node(target_object, element_name, element)
                      when BuilderHelpers::Element
                        build_element(target_object, element_name, element)
                      end
                  next if el == CONDITION_UNMET || el.blank?

                  if el.is_a?(Array)
                    el.each {|el| add_to_root.call(root, el) }
                    next
                  end

                  add_to_root.call(root, el)
                rescue StandardError => e
                  @document = nil
                  raise
                end
              end
              root
            end

            def build_conditional(target_obj, element_name, conditional_element)
              element, condition = conditional_element

              case condition
              when Proc
                return CONDITION_UNMET if !instance_exec(target_obj, &condition)
              else
                return CONDITION_UNMET if !__send__(condition)
              end

              case element
              when BuilderHelpers::RelationalNode
                return build_node(target_obj, element_name, element)
              when BuilderHelpers::Element
                return build_element(target_obj, element_name, element)
              end
            end

            def build_element(target_object, element_name, builder_element)
              el_value = fetch_element_value(target_object, builder_element.target_value)

              return if el_value.blank?

              return_element = Ox::Element.new(element_name)

              build_element_attributes(target_object, return_element, builder_element.attributes)

              return_element << el_value

              return_element
            end

            def build_node(target_object, node_name, node, use_target_object: false)
              node_target_obj = use_target_object ? target_object : fetch_node_value(target_object, node.target_object)

              return if node_target_obj.blank?

              node_elements = node.elements.inject({}) do |ret, ne|
                k = self.class.send(:transformed_key, ne.name)
                ret[k] = ne
                ret
              end

              Rails.logger.info node_elements.awesome_inspect
              if target_is_collection?(node_target_obj)
                Rails.logger.info "The result of node.multi_valued IS #{node.multi_valued}"
                return build_node_multi(node_target_obj, node_name, node) if node.multi_valued

                node_name = self.class.send(:transformed_key, node.xml_label) if node.xml_label.present?
                node_root = Ox::Element.new(node_name)
                build_node_attributes(node_target_obj, node_root, node.attributes)
                node_target_obj.each { |nt_obj| build_elements(node_root, nt_obj, node_elements) } if node_elements.present?

                return if node_is_blank?(node_root)

                return node_root
              end
              
              node_name = self.class.send(:transformed_key, node.xml_label) if node.xml_label.present?
              node_root = Ox::Element.new(node_name)
              build_node_attributes(node_target_obj, node_root, node.attributes)
              build_elements(node_root, node_target_obj, node_elements) if node_elements.present?

              node_value = fetch_node_value(node_target_obj, node.target_value) if node.target_value.present?
              node_root << node_value if node_value.present?

              return if node_is_blank?(node_root)

              node_root
            end

            def build_node_multi(node_target_objects, node_name, node)
              node_target_objects.map { |nto| build_node(nto, node_name, node, use_target_object: true) }.compact
            end

            def build_element_attributes(target_object, return_element, attributes_list = [])
              return if attributes_list.blank?

              attrs = fetch_element_attributes(target_object, attributes_list)

              return if attrs.blank?

              attrs.each_pair { |attr_name, attr_value| return_element[attr_name] = attr_value if attr_value }
            end
            alias build_node_attributes build_element_attributes

            def fetch_element_value(target_obj, element_target_value)
              return if element_target_value.blank?

              fetch_value(target_obj, element_target_value)
            end
            alias fetch_node_value fetch_element_value

            def node_is_blank?(node)
              node.attributes.blank? && node.nodes.blank?
            end

            def fetch_element_attributes(target_obj, element_attributes = [])
              return {} if element_attributes.blank?

              Rails.logger.info target_obj.awesome_inspect
              element_attributes.reduce({}) do |ret, el_attr|
                ret[el_attr.xml_label] = fetch_value(target_obj, el_attr.target_value)
                ret
              end
            end

            def fetch_value(target_obj, obj_attribute)
              case obj_attribute
              when Symbol, String then fetch_attribute_from_object_or_serializer(target_obj, obj_attribute)
              when Proc then instance_exec(target_obj, &obj_attribute)
              else
                raise Curator::Exceptions::CuratorError, "Unsupported type of obj_attribute: #{obj_attribute.class}"
              end
            end

            def fetch_attribute_from_object_or_serializer(target_obj, obj_attribute)
              has_method = @method_existence[obj_attribute.to_sym]
              has_method = @method_existence[obj_attribute.to_sym] = target_obj.respond_to?(obj_attribute) if has_method.nil?
              has_method ? target_obj.__send__(obj_attribute) : __send__(obj_attribute, target_obj)
            end

            def fetch_root_element_name
              name = root_name

              return name if root_namespace.blank?

              case root_namespace
              when TrueClass
                "#{name}#{namespace_separator}#{name}"
              when String, Symbol
                "#{root_namespace}#{namespace_separator}#{name}"
              else
                raise Curator::Exceptions::CuratorError, "Unsupported type of root_namespace: #{root_namespace.class}"
              end
            end

            def target_is_collection?(target_object)
              target_object.is_a?(Enumerable) && !target_object.is_a?(Struct)
            end

            def object_is_collection?
              @object.is_a?(Enumerable) && !@object.is_a?(Struct)
            end

            def xml_elements
              @_xml_elements
            end

            def root_attributes
              @_root_attributes
            end

            def root_name
              @_root_name.to_s
            end

            def root_namespace
              @_root_namespace
            end

            def namespace_separator
              @_namespace_separator.to_s
            end

            def xml_key_transform
              @_xml_key_transform.to_sym
            end
          end

          module ClassMethods
            attr_reader(*SCHEMA_BUILDER_DSL.keys)

            def inherited(subclass)
              super
              SCHEMA_BUILDER_DSL.each_key { |name| subclass.instance_variable_set("@#{name}", instance_variable_get("@#{name}").clone) }
            end

            def root_settings(name, root_namespace: nil, namespace_separator: ':', root_attributes: {})
              @_root_name = name
              @_root_namespace = root_namespace
              @_namespace_separator = namespace_separator
              @_root_attributes = root_attributes
            end

            # assigns elements that don't require attributes or block values
            def elements(*elements, if: nil)
              if_block = binding.local_variable_get(:if)
              assign_elements(elements, if_block)
            end

            def element(el_name, **options, &block)
              raise ArgumentError, 'No block given in element method' if block.blank?

              if_block = options.delete(:if)
              el = BuilderHelpers::Element.new(el_name.to_sym, **options, &block)
              @_xml_elements[transformed_key(el_name)] = if_block.blank? ? el : [el, if_block]
            end

            def node(node_name, **options, &block)
              raise ArgumentError, 'No block given in node method' if block.blank?

              if_block = options.delete(:if)
              n = BuilderHelpers::RelationalNode.new(node_name.to_sym, **options, &block)
              @_xml_elements[transformed_key(node_name)] = if_block.blank? ?  n : [n, if_block]
            end

            def multi_node(node_name, **options, &block)
              raise ArgumentError, 'No block given in multi node method' if block.blank?

              options = options.merge(multi_valued: true)
              node(node_name, **options, &block)
            end

            protected

            def assign_elements(els, if_block = nil)
              els.each do |el_name|
                el = BuilderHelpers::Element.new(el_name.to_sym)
                @_xml_elements[transformed_key(el_name)] = if_block.blank? ?  el : [el, if_block]
              end
            end

            def transformed_key(key)
              key = key.to_s

              if _root_namespace.present?
                key = case _root_namespace
                      when TrueClass
                        "#{_root_name}#{_namespace_separator}#{key}"
                      when String, Symbol
                        "#{_root_namespace}#{_namespace_separator}#{key}"
                      end
              end

              return key if _xml_key_transform.to_sym == :none

              case _xml_key_transform.to_sym
              when :camelize
                key.camelize
              when :camelize_lower
                key.camelize(:lower)
              when :snake
                key.underscore
              end.to_s
            end
          end
        end
      end
    end
  end
end
