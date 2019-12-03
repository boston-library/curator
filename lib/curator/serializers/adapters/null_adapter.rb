module Curator
  module Serializers
    class NullAdapter < Adapter
      def serializable_hash
        {}
      end

      def render
        nil
      end
    end
  end
end
