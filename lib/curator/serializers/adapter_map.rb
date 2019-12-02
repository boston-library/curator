# frozen_string_literal: true

module Curator
  module Serializers
    class AdapterMap
      attr_reader :adapters
      def initialize
        @adapters = Concurrent::Map.new
      end

      def [](adapter_key)
        @adapters.get_or_default(adapter_key, 'Curator::Serializers::NullAdapter').safe_constantize
      end

      def []=(adapter_key, adapter_name)
        @adapters.get_and_set(adapter_key, adapter_name)
      end
    end
  end
end
