module Curator
  module Serializers
    class NullAdapter < AdapterBase
      def initialize(_options = {}, &_block)
        @schema = nil
      end

      def serializable_hash(_record = nil, _serializer_params = nil)
        {}
      end
    end
  end
end
