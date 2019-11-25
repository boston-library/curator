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
        if include_attribute?(record, serialization_params)
          output_hash[key] = if method.is_a?(Proc)
            method.arity.abs == 1 ? method.call(record) : method.call(record, serialization_params)
          else
            record.public_send(method)
          end
        end
      end

      def include_attribute?(record, serialization_params)
        if conditional_proc.present?
          conditional_proc.call(record, serialization_params)
        else
          true
        end
      end
    end
  end
end
