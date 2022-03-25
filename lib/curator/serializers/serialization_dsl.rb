# frozen_string_literal: true

module Curator
  module Serializers
    module SerializationDSL
      extend ActiveSupport::Concern

      included do
        raise "#{self} is not Curator::Serializers::AbstractSerializer" unless Rails.env.test? || _is_serializer?(self)

        class << self
          attr_reader :_adapter_schemas
        end
        _reset_adapter_schemas!
        _inject_adapter_schema_builder_methods!
      end

      class_methods do
        def inherited(subclass)
          raise "#{subclass} is not inherited from Curator::Serializers::AbstractSerializer" unless _is_serializer?(subclass)

          super(subclass)
          subclass._reset_adapter_schemas!
          subclass._inject_adapter_schema_builder_methods!
        end

        protected

        def _inject_adapter_schema_builder_methods!
          Curator::Serializers.registered_adapter_keys.each { |key| _define_schema_builder_method_for_adapter(key) }
        end

        def _define_schema_builder_method_for_adapter(key)
          class_eval <<-RUBY, __FILE__, __LINE__ + 1
            class << self
              def build_schema_as_#{key}(&block)
                _define_adapter_schema_builder(adapter_key: '#{key}'.to_sym, &block)
              end
            end
          RUBY
        end

        # NOTE: redefining a schema for an adapter on an inherited class will create a new one
        def _define_adapter_schema_builder(adapter_key:, &block)
          raise 'NullAdapter cant be used this way' if adapter_key.to_sym == :null

          if superclass._has_adapter_schema?(adapter_key.to_sym)
            parent_adapter = superclass._schema_builder_for_adapter(adapter_key)
            adapter_klass = parent_adapter.class
            adapter_instance = adapter_klass.new(base_builder_class: parent_adapter.schema_builder_class, &block)
          else
            adapter_klass = Curator::Serializers.lookup_adapter(adapter_key.to_sym)
            adapter_instance = adapter_klass.new(&block)
          end

          _map_adapter_schema(adapter_key.to_sym, adapter_instance)
        end

        def _schema_builder_for_adapter(adapter_key)
          return _adapter_schemas[adapter_key] if _has_adapter_schema?(adapter_key)

          _adapter_schemas[:null]
        end

        def _is_serializer?(klass)
          klass <= Curator::Serializers::AbstractSerializer
        end

        def _has_adapter_schema?(adapter_key)
          return false unless defined?(@_adapter_schemas) && !@_adapter_schemas.nil?

          _adapter_schemas.key?(adapter_key)
        end

        def _reset_adapter_schemas!
          return @_adapter_schemas.clear if defined?(@_adapter_schemas)

          @_adapter_schemas = Concurrent::Map.new if @_adapter_schemas.nil?

          _map_null_adapter
        end

        def _map_null_adapter
          _map_adapter_schema(:null, Curator::Serializers.lookup_adapter(:null).new)
        end

        def _map_adapter_schema(adapter_key, adapter)
          @_adapter_schemas = Concurrent::Map.new unless defined?(@_adapter_schemas) && !@_adapter_schemas.nil?
          _adapter_schemas.merge_pair(adapter_key, adapter) { |v| v }
        end
      end
    end
  end
end
