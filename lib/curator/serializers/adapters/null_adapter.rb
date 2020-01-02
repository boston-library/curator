# frozen_string_literal: true

module Curator
  module Serializers
    class NullAdapter < AdapterBase
      def initialize(_options = {}, &_block)
        @schema = nil
      end

      def serializable_hash(_record, _serializer_params)
        {}
      end

      def render(record, serializer_params)
        serializable_hash(record, serializer_params)
      end
    end
  end
end
