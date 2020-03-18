# frozen_string_literal: true

module Curator
  module Serializers
    class NullAdapter < AdapterBase
      def_delegators :schema, :root
      
      def initialize(_options = {}, &_block)
        @schema = Curator::Serializers::Schema.new(root: nil, options: {})
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
