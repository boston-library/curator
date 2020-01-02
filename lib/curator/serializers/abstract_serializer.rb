# frozen_string_literal: true

module Curator
  module Serializers
    class AbstractSerializer
      extend Forwardable
      include SerializationDSL
      attr_reader :record, :adapter, :serializer_params

      def_delegator :@adapter, :serializable_hash, :adapter_serialized_hash

      def_delegator :@adapter, :render, :adapter_render

      def initialize(record, adapter_key, serializer_params = {})
        @record = record
        @adapter = self.class._schema_for_adapter(adapter_key)
        @serializer_params = serializer_params.dup.slice(:if, :unless, :fields, :included).reverse_merge!(adapter_key: adapter_key)
      end

      def serializable_hash
        adapter_serializable_hash(record, serializer_params)
      end

      def render
        adapter_render(record, serializer_options)
      end
    end
  end
end
