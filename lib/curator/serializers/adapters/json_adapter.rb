# frozen_string_literal: true

module Curator
  module Serializers
    class JSONAdapter < AdapterBase
      def initializer(base_builder_klass: Curator::Serializers::SchemaBuilders::JSON, &block)
        super(base_builder_klass: base_builder_klass)
        @schema_builder_class = Class.new(base_builder_class, &block)
      end

      def serializable_hash(resource, params = {})
        @schema_builder_class.new(resource, params).serializable_hash
      end

      def serialize(resource, params = {})
        root_key = params.delete(:root_key)
        meta = params.delete(:meta) || {}
        @schema_builder_class.new(resource, params).serialize(root_key: root_key, meta: meta)
      end
    end
  end
end
