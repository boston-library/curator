# frozen_string_literal: true

module Curator
  module Serializers
    class Link
      attr_reader :key, :method

      def initialize(key:, method:)
        @key = key
        @method = method
      end
    end
  end
end
