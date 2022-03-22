# frozen_string_literal: true

module Curator
  module Serializers
    class Meta < Attribute
      attr_reader :key, :method
      def initialize(key:, method:, **_kwargs)
        @key = key
        @method = method
        raise 'Method must be a proc, lamda or block!' unless @method.is_a?(Proc)
      end

      def include_value?(_record = nil, _serializer_params = {})
        true # Always include meta tags if avialable
      end

      # NOTE: Only public methods and blocks can generate meta
      def read_for_serialization(record, serializer_params = {})
        return if !method.is_a?(Proc)

        method.arity.abs == 1 ? method.call(record) : method.call(record, serializer_params.dup)
      end
    end
  end
end
