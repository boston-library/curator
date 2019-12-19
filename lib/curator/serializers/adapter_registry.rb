# frozen_string_literal: true

module Curator
  module Serializers
    class AdapterRegistry
      include Singleton

      def initialize
        @_adapters = Concurrent::Map.new
      end

      def register(key:, adapter:)
        adapter_klass = adapter.is_a?(String) ? adapter.safe_constantize : adapter
        raise 'No Valid adapter class given' if adapter_klass.blank?

        unless _is_adapter?(adapter_klass)
          raise "#{adapter} is not a kind of Curator::Serializers::AdapterBase!"
        end

        raise "#{registry_key} for #{adapter} has already been set!" if has_adapter?(key)

        _adapters[key.to_sym] = adapter
      end

      def [](key)
        _adapters[key.to_sym]
      end

      def has_adapter?(key)
        _adapters.key?(key.to_sym)
      end

      def clear!
        _adapters.clear
      end

      private

      attr_reader :_adapters

      def _is_adapter?(klass)
        klass <= Curator::Serializers::AdapterBase
      end
    end
  end
end
