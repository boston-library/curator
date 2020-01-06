# frozen_string_literal: true

module Curator
  module Serializers
    class Node < Attribute
      extend Forwardable
      attr_reader :schema

      def_delegators :schema, :root, :attribute, :attributes, :node, :has_one, :belongs_to, :has_many

      def initialize(key:, method: nil, options: {}, &block)
        super(key: key, options: options.dup)
        raise 'Node requires a Block!' unless block_given?

        @schema = Schema.new(root: key, options: options.dup.slice(:key_transform_method, :cache_enabled, :cache_options))
        instance_eval(&block)
      end

      def read_for_serialization(record, serializer_params = {})
        schema.serialize(record, serializer_params.dup)
      end

      def include_value?(record, serializer_params = {})
        return true if !@options.key?(:if) && !@options.key?(:unless)

        conditions_passed?(record, serializer_params.dup)
      end
    end
  end
end
