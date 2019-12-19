# frozen_string_literal: true

module Curator
  module Serializers
    extend ActiveSupport::Autoload

    class << self
      def register_adapter(key:, adapter:)
        _adapter_registry.register(key: key, adapter: adapter)
      end

      def lookup_adapter(key)
        raise "Unknown adapter #{key}" unless _adapter_registry.has_adapter?(key)
        __adapter_registry[key]
      end
      private
      def _adapter_registry
        AdapterRegistry.instance
      end
    end

    eager_autoload do
      autoload :AdapterBase
      autoload :AdapterRegistry
      autoload :Schema
      autoload :AbstractSerializer
      autoload_under 'adapters' do
        autoload :NullAdapter
        autoload :JSONAdapter
        autoload :XMLAdapter
      end
      autoload_under 'schema' do
        autoload :Attribute
        autoload :Link
        autoload :Meta
        autoload :Node
        autoload :Relation
      end
    end
  end
end
Curator::Serializers.register_adapter(key: :json, adapter: Curator::Serializers::JSONAdapter)
Curator::Serializers.register_adapter(key: :null, adapter: Curator::Serializers::NullAdapter)
Curator::Serializers.register_adapter(key: :xml,  adapter: Curator::Serializers::XMLAdapter)
