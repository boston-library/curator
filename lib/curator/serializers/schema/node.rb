# frozen_string_literal: true

module Curator
  module Serializers
    #Used for attr_json models and relationships
    attr_reader :_root, :_schema
    class Node
      def initialize(root:, options: {}, &block)
        raise "Root Key must be defined on Nested Node" if root.blank? #root key is also a method
        @_root = root
        raise "Node requires a Block!" unless block_given?
        @_schema = Schema.new(root: @_root, &block)
      end

      def add_serializable_attr(attribute)
        super(attribute)
      end

      def serialize(record, serializer_params = {})
        super(record.public_send(root_key), serializer_params)
      end

      def include_value?(record, serializer_params = {})
        record.respond_to?(root_key) && conditions_passed?(record.public_send(root_key), serializer_params)
      end

      def conditions_passed?(record, serializer_params = Concurrent::Hash.new)
        return true if !@options.key?(:if) && !@options.key?(:unless)

        if_cond, unless_cond = @options[:if], @options[:unless]
        if if_cond.present?
         res = if_cond.call(record, serializer_params)
        elsif unless_cond.present?
         res = !unless_cond.call(record, serializer_params)
        else
         res = true
        end
        res
      end

    end
  end
end
