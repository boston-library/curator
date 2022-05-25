# frozen_string_literal: true

module Curator
  module Serializers
    class JSONAdapter < AdapterBase
      # @param :base_builder_class [Class[default = Curator::Serializers::SchemaBuilders::JSON]] class to inherit from. NOTE: this should have a builder DSL defined
      # @param &block, block for configuring the class with dsl or instance related methods
      # ie JSONAdapter.new do
      #     attributes :some_attr1, :some_attr2
      # See Curator::Serializers::SchemaBuilders::JSON defined in ../schema_builders/json.rb for link to reference documentation
      # @return [Curator::Serializers::JSONAdapter instance]
      def initialize(base_builder_class: Curator::Serializers::SchemaBuilders::JSON, &block)
        super(base_builder_class: base_builder_class)
        @schema_builder_class = Class.new(base_builder_class, &block)
      end

      def serializable_hash(resource, params = {})
        schema_builder_class.new(resource, params: params).serializable_hash
      end

      def serialize(resource, params = {})
        root_key = params.delete(:root_key)
        meta = params.delete(:meta) || {}
        schema_builder_class.new(resource, params: params).serialize(root_key: root_key, meta: meta)
      end
    end
  end
end
