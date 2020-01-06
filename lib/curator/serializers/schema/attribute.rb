# frozen_string_literal: true

module Curator
  module Serializers
    class Attribute
      attr_reader :key, :method
      def initialize(key:, method: nil, options: {})
        @key = key
        @method = method || key
        @options = options
      end

      def serialize(record, serialization_params = {})
        read_for_serialization(record, serialization_params.dup)
      end

      def include_value?(record, serializer_params = {})
        return true if !@options.key?(:if) && !@options.key?(:unless) && !serializer_params.key?(:fields)

        conditions_passed?(record, serializer_params.dup) && fields_included?(serializer_params.dup)
      end

      # NOTE: Attributes can be read as blocks and public mehods but also read with read attribute for serialization method
      def read_for_serialization(record, serializer_params = {})
        if method.is_a?(Proc)
          method.arity.abs == 1 ? method.call(record) : method.call(record, serializer_params.dup)
        elsif record.class.respond_to?(:has_attribute?) && record.class.has_attribute?(key) && record.respond_to?(:read_attribute_for_serialization)
          record.read_attribute_for_serialization(method)
        else
          record.public_send(method)
        end
      end

      protected

      def conditions_passed?(record, serializer_params = {})
        return true if !@options.key?(:if) && !@options.key?(:unless)

        if_cond, unless_cond = @options[:if], @options[:unless]
        if if_cond.present?
          res = if_cond.call(record, serializer_params.dup)
        elsif unless_cond.present?
          res = !unless_cond.call(record, serializer_params.dup)
        else
          res = true
        end
        res
      end

      def fields_included?(serializer_params = {})
        return true if !serializer_params.key?(:fields)

        serializer_params[:fields].include?(key)
      end
    end
  end
end
