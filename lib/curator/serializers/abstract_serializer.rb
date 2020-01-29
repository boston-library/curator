# frozen_string_literal: true

module Curator
  module Serializers
    class AbstractSerializer
      extend Forwardable
      include Serializers::SerializationDSL
      attr_reader :record, :adapter, :serializer_params

      def_delegator :adapter, :serializable_hash, :adapter_serialized_hash

      def_delegator :adapter, :render, :adapter_render

      def initialize(record, adapter_key, serializer_params = {})
        @record = record
        adapter_key = :null if record.blank?
        @adapter = self.class.send(:_schema_for_adapter, adapter_key)
        # NOTE: The reason we reverse_merge the adapter key into the serializer params is so any relationships serialized will know which apater they are serializing for
        @serializer_params = serializer_params.dup.merge(adapter_key: adapter_key)
      end

      def serializable_hash
        adapter_serialized_hash(record, serializer_params)
      end

      def render
        adapter_render(record, serializer_params)
      end
    end
  end
end
