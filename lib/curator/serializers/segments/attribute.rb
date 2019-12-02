# frozen_string_literal: true

module Curator
  module Serializers
    class Attribute
      attr_reader :key, :method, :if_proc, :unless_proc

      def initialize(key:, method:, options: {})
        @key = key
        @method = method
        @if_proc = options[:if]
        @unless_proc = options[:unless]
      end
      def serialize(record, serialization_params, output_hash)
        output_hash[key] = read_attribute_for_serialization(record, serialization_params)  if include_attribute?(record, serialization_params)
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
        if method.is_a?(Proc)
          method.arity.abs == 1 ? method.call(record) : method.call(record, serialization_params)
        elsif record.respond_to?(:read_attribute_for_serialization, method)
          record.read_attribute_for_serialization(method)
        else
          record.public_send(method)
        end
      end
    end
  end
end
