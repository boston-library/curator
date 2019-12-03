# frozen_string_literal: true

module Curator
  module Serializers
    class Attribute < SerializedAttr
      def serialize(record, serialization_params = {})
        return nil unless include_attribute?(record, serialization_params)
        read_attribute_for_serialization(record, serialization_params)
      end

      def include_attribute?(record, serializer_params)
        return true if @options[:if].blank? && @options[:unless].blank?

        # return false if @options[:fields] && !@options[:fields].include?(key) so this at the class level

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

      def read_attribute_for_serialization(record, serializer_params = {}, *args)
        if method.is_a?(Proc)
          method.arity.abs == 1 ? method.call(record) : method.call(record, serializer_params)
        elsif record.respond_to?(:read_attribute_for_serialization, method)
          record.read_attribute_for_serialization(method)
        else
          record.public_send(method)
        end
      end
    end
  end
end
