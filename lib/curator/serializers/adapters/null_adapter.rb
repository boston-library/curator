module Curator
  module Serializers
    class NullAdapter < Adapter
      def initialize(_schema)
        @schema = nil
      end

      def serializable_hash(_record, _serializer_options = nil)
        Concurrent::Hash.new
      end
    end
  end
end
