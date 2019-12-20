# frozen_string_literal: true

module Curator
  module Serializers

    #Used for attr_json models and relationships
    class Node < Attribute
      extend Forwardable
      attr_reader :schema

      def_delegators :@schema, :attribute, :attributes, :node, :meta, :link, :has_one, :belongs_to, :has_many

      def initialize(key:, options: {}, &block)
        super(key: key, options: options)
        raise "Node requires a Block!" unless block_given?
        @schema = Schema.new(root: @key)
        instance_eval(&block)
      end

      def read_for_serialization(record, serializer_params = {})
        Concurrent::Hash[@key, schema.serialize(record, serializer_params)]
      end

      def include_value?(record, serializer_params = {})
        return true if !@options.key?(:if) && !@options.key?(:unless)
        conditions_passed?(record, serializer_params)
      end
    end
  end
end
