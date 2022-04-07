# frozen_string_literal: true

module Curator
  module Serializers
    class XMLAdapter < AdapterBase
      # NOTE XML Adapters don't include meta/link facets
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
        return @builder_instance if defined?(@builder_instance) && !@builder_instance.blank?

        @builder_instance = schema_builder_class.new(record, params)
      end
    end
  end
end
