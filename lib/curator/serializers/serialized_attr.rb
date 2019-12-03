# frozen_string_literal: true

module Curator
  module Serializers
    class SerializedAttr
      attr_reader :key, :method

      def initialize(key: nil, method: nil, options: {}, **_)
        @key = key
        @method = method || key
        @options = options
      end

      def serialize(resource, serializer_params = {})
        raise NotImplementedError
      end

      def include_attribute?(record, serializer_params = {})
        raise NotImplementedError
      end

      def read_attribute_for_serialization(record, serializer_params = {}, *args)
        raise NotImplementedError
      end
    end
  end
end
