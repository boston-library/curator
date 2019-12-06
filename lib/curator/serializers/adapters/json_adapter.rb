# frozen_string_literal: true

module Curator
  module Serializers
    class JSONAdapter < Adapter

      def serializable_hash
      end

      # def render
      #   Oj.dump(serializable_hash(serializer_options))
      # end
    end
  end
end
