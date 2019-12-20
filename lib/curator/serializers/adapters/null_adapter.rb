module Curator
  module Serializers
    class NullAdapter < AdapterBase
      def initialize(_options = {}, &_block)
        @schema = nil
      end

      def serializable_hash(_record, _serializer_params)
        {}
      end

      def render(_record, _serializer_params)
        serializable_hash(_record, _serializer_params)
      end
    end
  end
end
