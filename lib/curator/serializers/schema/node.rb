# frozen_string_literal: true

module Curator
  module Serializers
    class Node < Attribute
      extend Forwardable
      attr_reader :node_schema

      def_delegators :node_schema, :root, :attribute, :attributes, :node, :has_one, :belongs_to, :has_many

      def initialize(key:, options: {}, &block)
        super(key: key, options: options.dup)
        raise 'Node requires a Block!' unless block_given?

        aquire_target_method!(options.fetch(:target, nil), key)

        @node_schema = Schema.new(root: key, options: options.dup.slice(:key_transform_method, :cache_enabled, :cache_options))
        instance_eval(&block)
      end

      def read_for_serialization(record, serializer_params = {})
        target_val = super(record, serializer_params.dup) if method
        target_val = record if target_val.blank?

        node_schema.serialize(target_val, serializer_params.dup)
      end

      def include_value?(record, serializer_params = {})
        return true if !@options.key?(:if) && !@options.key?(:unless)

        conditions_passed?(record, serializer_params.dup)
      end

      private

      def aquire_target_method!(target, key)
        if target == :key
          @method = key
        elsif target.is_a?(Proc)
          @method = target
        else
          @method = nil
        end
      end
    end
  end
end
