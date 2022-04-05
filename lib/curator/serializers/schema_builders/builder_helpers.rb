# frozen_string_literal: true

module Curator
  module Serializers
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

        def initialize(name, target_value: nil, &block)
          @name = name
          @xml_label = xml_label.present? ? xml_label : name
          @target_value = target_value.present? ? target_value : name.to_sym
          @attributes = []
          instance_exec(&block) if block_given?
        end

        def attribute(attr_name, xml_label: nil, &block)
          attr = block_given? ? Attribute.new(attr_name.to_sym, xml_label: xml_label, &block) : Attribute.new(attr_name, xml_label: xml_label)
          attributes << attr
        end
      end

      class RelationalNode < Element
        attr_reader :elements, :multi_root

        # Note target value is the method or relation we will be passing as the target object
        def initialize(name, target_value: nil, multi_root: false, &block)
          @elements = []
          @multi_root = multi_root
          super
        end

        def element(el_name, target_value: nil, &block)
          el = block_given? ? Element.new(el_name, target_value: target_value, &block) : Element.new(el_name, target_value: target_value)
          @elements << el
        end

        def node(node_name, target_value: nil, multi: false, &block)
          raise ArgumentError, 'No block given in node method' if block.blank?

          @elements << self.class.new(node_name, target_value: target_value, mutli_root: multi, &block)
        end
      end

      module XMLBuilder
        extend ActiveSupport::Concern

        SCHEMA_BUILDER_DSL = { _xml_elements: {}, _root_name: nil, _root_namespace: nil, _namespace_separator: ':', _root_attributes: {} , _root_element: nil, _xml_key_transform: :camelize_lower }.freeze
        private_constant :SCHEMA_BUILDER_DSL

        CONDITION_UMNET = Object.new.freeze
        private_constant :CONDITION_UMNET

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
            Ox.dump(document)
          end

          def serializable_document
            document
          end

          protected

          def root_element
            return @_root_element if defined?(@_root_element) && !@_root_element.nil?

            @_root_element = Ox::Element.new(fetch_root_element_name)

            root_attributes.each_pair { |attr_name, attr_value| _@root_element[attr_name] = attr_value }

            @_root_element
          end

          def document
            return @document if defined?(@document) && !@document.nil?

            @document = Ox::Document.new(version: '1.0', encoding: 'UTF-8')

            if collection?
              object.each { |obj| build_elements(root_element, object, xml_elements) }
            else
              build_elements(root_element, object, xml_elements)
            end
            @document << root_element
            @document
          end

          private

          def add_to_root(root, xml_el)
            lambda do |root, xml_el|
              root << xml_el
            end
          end

          def build_elements(root, target_object, elements)
            elements.each_pair do |element_name, element|
              begin
                el = case element
                    when Array
                      build_conditional(target_object, element_name, element)
                    when BuilderHelpers::Element
                      build_element(target_obj, element_name, element)
                    when BuilderHelpers::RelationalNode
                      build_node(target_obj, element_name, element)
                    end
                next if el == CONDITION_UMNET

                if el.is_a?(Array)
                  el.each {|el| add_to_root.call(root, el) }
                  next
                end

                add_to_root.call(root, el)
              rescue StandardError => e
                Rails.logger.error(e.message)
              end
            end
            root
          end

          def build_conditional(target_obj, element_name, conditional_element)
            element, condition = conditional_element

            case condition
            when Proc
              return CONDITION_UMNET if !instance_exec(target_obj, &condition)
            else
              return CONDITION_UMNET if !__send__(condition)
            end

            case element
            when BuilderHelpers::Element
              return build_element(target_obj, element_name, element)
            when BuilderHelpers::Node
              return build_node(target_obj, element_name, element)
            end
          end

          def build_element(target_object, element_name, builder_element)
            return_element = Ox::Element.new(element_name)

            el_attrs = fetch_element_attributes(target_object, builder_element.attributes)
            el_attrs.each_pair { |attr_name, attr_value| return_element[attr_name] = attr_value }

            el_value = fetch_element_value(target_object, builder_element)
            return_element << el_value if el_value.present?
            return_element
          end

          def build_node(target_obj, node_name, node)
            node_target_obj = fetch_value(target_obj, node.target_value)

            node_elements = node.elements.inject({}) do |ret, ne|
              k = self.class.send(:transformed_key, ne.name)
              ret[k] = ne
            end

            if node_target_obj.is_a?(Enumerable) && !node_target_obj.is_a?(Struct)
              return build_node_multi_root(node_target_obj, node_name, node) if node.multi_root

              node_root = Ox::Element.new(node_name)
              node_attributes = fetch_node_attributes(node_target_obj, node.attributes)

              node_target_obj.each { |nt_obj| build_elements(node_root, nt_obj, node_elements) }
            else
              node_root = Ox::Element.new(node_name)
              node_attributes = fetch_node_attributes(node_target_obj, node.attributes)
              node_attributes.each_pair { |attr_name, attr_value| node_root[attr_name] = attr_value }
              build_elements(node_root, node_target_obj, node_elements)
            end
            node_root
          end

          def build_node_multi_root(node_target_objects, node_name, node_elements, node_attributes)
            node_target_objects.map do |node_target_obj|
              node_root = Ox::Element.new(node_name)
              node_attributes = fetch_node_attributes(node_target_obj, node_attributes)
              node_attributes.each_pair { |attr_name, attr_value| node_root[attr_name] = attr_value }
              build_elements(node_root, node_target_obj, node_elements)
              node_root
            end
          end

          def fetch_element_attributes(target_obj, element_attributes = [])
            return {} if element_attributes.blank?

            element_attributes.reduce({}) do |ret, el_attr|
              ret[el_attr.xml_label] = fetch_value(target_obj, el_attr.target_value)
              ret
            end
          end
          alias fetch_node_attributes fetch_element_attributes

          def fetch_element_value(target_obj, element)
            fetch_value(target_obj, element.target_value)
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
            has_method ? target_obj.__send__(obj_attribute) : __send__(obj_attribute, target_object)
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

          def collection?
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
            @_root_namespace.to_s
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
            n = BuilderHelpers::Node.new(node_name.to_sym, **options, &block)
            @_xml_elements[transformed_key(el_name)] = if_block.blank? ?  n : [n, if_block]
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
                      "#{_root_namespace}#{name}#{key}"
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
