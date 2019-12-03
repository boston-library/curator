# frozen_string_literal: true

module Curator
  module Serializers
    class JSONAdapter < Adapter

      def serializable_hash
      end
      alias_method :as_json, :serializable_hash

      def render
        Oj.dump(serializable_hash(serializer_options))
      end
      alias_method :to_json, :render

    end
  end
end
