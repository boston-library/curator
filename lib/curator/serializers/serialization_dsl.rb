# frozen_string_literal: true

module Curator
  module Serializers
    module SerializationDSL
      extend ActiveSupport::Concern
      included do
        class << self
          protected

          attr_reader :_adapter_schemas
        end
        reset_adapter_schemas!
      end

      class_methods do
        def inherited(subclass)
          raise "#{subclass} is not inherited from Curator::Serializers::AbstractSerializer" unless _is_serializer?(subclass)

          super(subclass)
          subclass._reset_adapter_schemas!
          subclass._inherit_schemas
        end

        def define_adapter_schema(adapter_key:, root: nil, options: {}, &block)
          raise 'NullAdapter cant be used this way' if adapter_key.to_sym == :null

          adapter_schema_klass = Curator::Serializers.lookup_adapter(adapter_key.to_sym)
          schema_options = options.dup.slice(:cached, :cached_length, :race_condition_ttyl, :key_transform_method)
          # TODO: Think of more options to set up at the schema level.
          schema_options[:adapter] = adapter.to_sym
          schema_options[:root] = root.to_sym if root

          _map_schema_adapter(adapter, adapter_schema_klass.new(schema_options, &block))
        end

        protected

        def _schema_for_adapter(adapter_key)
          return _adapter_schemas[adapter_key] if _adapter_schemas.key?(adapter_key)

          _adapter_schemas[:null]
        end

        def _is_serializer?(klass)
          klass <= Curator::Serializers::AbstractSerializer
        end

        def _inherit_schemas
          _adapter_schemas.each_pair { |k, v| subclass._adapter_schemas.compute_if_absent(k) { v } }
        end

        def _reset_adapter_schemas!
          return @_adapter_schemas.clear if defined? @_adapter_schemas

          @_adapter_schemas = Concurrent::Map.new if @_adapter_schemas.nil?

          _map_null_adapter
        end

        def _map_null_adapter
          map_schema_adapter(:null, Curator::Serializers.lookup_adapter(:null).new)
        end

        def _map_schema_adapter(adapter_key, schema_adapter)
          @_adapter_schemas = Concurrent::Map.new unless defined?(@_adapter_schemas) && !@_adapter_schemas.nil?
          _adapter_schemas.merge_pair(adapter_key, schema_adapter)
        end
      end
    end
  end
end
