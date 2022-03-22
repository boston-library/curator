# frozen_string_literal: true

module Curator
  module Serializers
    class XMLAdapter < AdapterBase
      # NOTE XML Adapters don't include meta/link facets
      def initializer(base_builder_klass:, &block)
        super(base_builder_klass: base_builder_klass)
        @schema_builder_class = Class.new(base_builder_class, &block)
      end

      def serialize(record, serializer_params = {})
        schema_builder_class.new(record, serializer_params).serialize
      end
    end
  end
end
