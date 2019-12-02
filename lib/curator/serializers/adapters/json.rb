# frozen_string_literal: true

module Curator
  module Serializers
    class JSON < Adapter
      def serializable_hash
      end

      alias_method :to_hash, :serializable_hash
      def as_json(options = {})
        serializable_hash(options)
      end

      def to_json(options = {})
        Oj.dump(serializable_hash(options))
      end
    end
  end
end
