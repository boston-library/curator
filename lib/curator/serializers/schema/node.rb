# frozen_string_literal: true

module Curator
  module Serializers
    class Node < Attribute
      extend Forwardable
      attr_reader :schema

      def_delegators :schema, :root, :attribute, :attributes, :node, :has_one, :belongs_to, :has_many

      def initialize(key:, options: {}, &block)
        super(key: key, options: options.dup)
        raise 'Node requires a Block!' unless block_given?

        aquire_target_method!(options.fetch(:target, nil), key)

        @schema = Schema.new(root: key, options: options.dup.slice(:key_transform_method, :cache_enabled, :cache_options))
        instance_eval(&block)
      end

      def read_for_serialization(record, serializer_params = {})
        value = super(record, serializer_params.dup) if method
        value = record if value.blank?

        schema.serialize(value, serializer_params.dup)
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
