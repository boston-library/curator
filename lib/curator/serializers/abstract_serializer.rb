module Curator
  module Serializers
    class AbstractSerializer
      extend Forwardable
      include SerializationDSL
      attr_reader :record, :adapter, :serializer_params

      def_delegator :@adapter, :serializable_hash, :adapter_serialized_hash

      def_delegator :@adapter, :render, :adapter_render

      def initialize(record, adapter_key, serializer_options = {})
        @record = record
        @adapter = self.class._schema_for_adapter(adapter_key)
        @serializer_options = serializer_options.slice(:if, :unless, :fields, :included)
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
