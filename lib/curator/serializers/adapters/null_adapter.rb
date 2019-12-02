module Curator
  module Serializers
    class NullAdapter < Adapter
      def serializable_hash
        {}
      end

      def render
        serializable_hash
      end
    end
  end
end
