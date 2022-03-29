# frozen_string_literal: true

module Curator
  module Serializers
    class XMLAdapter < AdapterBase
      # NOTE XML Adapters don't include meta/link facets
      def initialize(base_builder_class: Curator::Serializers::SchemaBuilders::JSON, &block)
        super(base_builder_class: base_builder_class)
        @schema_builder_class = Class.new(base_builder_class, &block)
      end

      def serializable_hash(record, params = {})
        schema_builder_class.new(record, params).serializable_hash
      end

      def serialize(record, params = {})
        schema_builder_class.new(record, params).serialize
      end
    end
  end
end
