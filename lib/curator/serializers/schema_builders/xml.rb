# frozen_string_literal: true

module Curator
  module Serializers
    module SchemaBuilders
      class XML
        attr_reader :object, :params

        def initialize(object, params: {})
          @object = object
          @params = params
          @method_existence = {} # Cache for `respond_to?` result
        end

        def serialize
        end

        def serializable_hash
        end

        alias to_h serializable_hash
      end

      module XmlResource
        extend ActiveSupport::Concern
        BUILDER_DSL = { _elements: {}, _root_document_key: nil, _root_document_attributes: {} }
        private_constant :BUILDER_DSL

        class Element
          attr_reader :name, :attributes, :if_block

          def initialize(name, attributes = [], if_block)
            @name = name.to_sym
            @attributes = attributes
            @if_block = if_block
          end
        end

        module InstanceMethods

        end

        module ClassMethods
          attr_reader(*DSLS.keys)

          def inherited(base)
            super
            BUILDER_DSL.each_key { |name|  base.instance_variable_set("@#{name}", instance_variable_get("@#{name}").clone) }
          end

          def elements(*)
          end

          def element(*)
          end

          def assign_elements(*)
          end
        end
      end
    end
  end
end
