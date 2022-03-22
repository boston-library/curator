# frozen_string_literal: true

module Curator
  module Serializers
    class AbstractSerializer
      include Serializers::SerializationDSL

      attr_reader :record, :adapter, :params

      def initialize(record, params = {}, adapter_key: :json)
        @record = record
        adapter_key = :null if record.blank?
        @params = params
        @adapter = self.class.send(:_schema_for_adapter, adapter_key)
      end

      def serializable_hash
        adapter.serializable_hash(record, params)
      end

      def serialize
        adapter.serialize(record, params)
      end

      alias render serialize
    end
  end
end
