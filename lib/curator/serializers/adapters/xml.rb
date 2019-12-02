# frozen_string_literal: true

module Curator
  module Serializers
    class XML < Adapter
      alias :to_hash :serializable_hash

      def serializable_hash()
      end

      def to_xml()
        # Oj.dump(serializable_hash(options))
      end
    end
  end
end
