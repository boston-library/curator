# frozen_string_literal: true

module Curator
  module Serializers
    extend ActiveSupport::Autoload

    class << self
      def register_adapter(key:, adapter:)
        _adapter_registry.register(key: key, adapter: adapter)
      end

      def lookup_adapter(key)
        return _adapter_registry[key] if _adapter_registry.has_adapter?(key)

        raise "Unknown adapter #{key}"
      end

      def reset_adapter_registry!
        _adapter_registry.clear!
      end

      def registered_adapter_keys(exclude_null = true)
        _adapter_registry.keys(exclude_null)
      end

      private

      def _adapter_registry
        AdapterRegistry.instance
      end
    end

    def self.setup!
      reset_adapter_registry!
      register_adapter(key: :null, adapter: NullAdapter)
      register_adapter(key: :json, adapter: JSONAdapter)
      register_adapter(key: :xml,  adapter: XMLAdapter)
      register_adapter(key: :mods, adapter: ModsAdapter)
    end

    eager_autoload do
      autoload :AdapterBase
      autoload :AdapterRegistry
      autoload :SchemaBuilders
      autoload :AbstractSerializer
      autoload :SerializationDSL
      autoload_under 'adapters' do
        autoload :NullAdapter
        autoload :JSONAdapter
        autoload :XMLAdapter
        autoload :ModsAdapter
      end
    end
  end
end
