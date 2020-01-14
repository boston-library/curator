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

        validate_adapter!(key, adapter, adapter_klass)

        _adapters.compute_if_absent(key.to_sym) { adapter }
        true
      end

      def [](key)
        _adapters[key.to_sym]
      end

      def has_adapter?(key)
        _adapters.key?(key.to_sym)
      end

      def keys(exclude_null = true)
        exclude_null ? _adapters.keys - [:null] : _adapters.keys
      end

      def clear!
        _adapters.clear
      end

      private

      attr_reader :_adapters

      def validate_adapter!(key, adapter, adapter_klass)
        raise 'No valid adapter class given' if adapter_klass.blank?

        raise "#{adapter} is not a kind of Curator::Serializers::AdapterBase!" unless _is_adapter?(adapter_klass)

        raise "#{key} for #{adapter} has already been registered!" if has_adapter?(key)
      end

      def _is_adapter?(klass)
        klass <= Curator::Serializers::AdapterBase
      end
    end
  end
end
