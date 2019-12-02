# frozen_string_literal: true

module Curator
  module Serializers
    class Segment
      attr_reader :key, :method, :if_cond, :unless_cond

      def initialize(key:, method:, options: {})
        @key = key
        @method = method
        @if_cond = options[:if]
        @unless_cond = options[:unless]
      end

      def serialize(record, serialization_params, output_hash)
        fail "Not Implemented at the base level!"
      end

      def include_attribute?(record, serialization_params)
        if if_cond.present?
          if_cond.call(record, serialization_params)
        elsif unless_cond.present?
          unless_cond.call(record, serialization_params)
        else
          true
        end
      end

      protected
      def read_attribute_for_serialization(record, serialization_params)
        fail "Not Implemented at the base level!"
      end
    end
  end
end
