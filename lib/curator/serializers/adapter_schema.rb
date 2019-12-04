# frozen_string_literal: true

module Curator
  module Serializers

    #TODO - Move this into a class to allow applications to make custom adapters for different formats
    ADAPTER_CLASS_REGISTRY = {
      null: 'Curator::Serializers::NullAdapter',
      json: 'Curator::Serializers::JSONAdapter',
      xml: 'Curator::Serializers::XMLAdapter'
    }.freeze

    class AdapterSchema
      attr_reader :_adapter_cache
      def initialize
        @_adapter_cache = Concurrent::Map.new
      end

      def add_schema_for(adapter_key: :null, resource_object: NullResource.new, &block)
        @_adapter_cache.fetch_or_store(adapter_key, resource_object)
        yield self[adapter_key] if block_given?
      end

      def [](key)
        raise "Unknown adapter_key #{key}" unless @adapter_cache.key?(key)
        @_adapter_cache.fetch(key)
      end
    end
  end
end
