# frozen_string_literal: true

module Curator
  module Serializers
    class NullAdapter < AdapterBase
      def initialize(_options = {}, &_block)
        @schema = nil
      end

      def serializable_hash(record = nil, serializer_params = {})
        return Concurrent::Array.new if record.respond_to?(:each) && serializer_params.dup.fetch(:for_relation, false)

        Concurrent::Hash.new
      end

      def render(record = nil, serializer_params = {})
        serializable_hash(record, serializer_params)
      end
    end
  end
end