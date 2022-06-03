# frozen_string_literal: true

module Curator
  module Serializers
    class XMLAdapter < AdapterBase
      # Base XML adapter for Serializing data as xml
      def initialize(base_builder_class: Curator::Serializers::SchemaBuilders::XML, &block)
        super(base_builder_class: base_builder_class)
        @schema_builder_class = Class.new(base_builder_class, &block)
      end

      def serializable_document(record, params = {})
        builder(record, params).serializable_document
      end

      def serializable_hash(record, params = {})
        builder(record, params).serializable_hash
      end

      def serialize(record, params = {})
        builder(record, params).serialize
      end

      protected

      def builder(record, params = {})
        schema_builder_class.new(record, params)
      end
    end
  end
end
