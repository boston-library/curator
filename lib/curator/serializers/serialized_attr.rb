# frozen_string_literal: true

module Curator
  module Serializers
    class SerializedAttr
      attr_reader :key, :method

      def initialize(key: nil, method: nil, options: {}, **_)
        @key = key
        @method = method || key
        @options = options
      end

      def serialize(resource, serializer_params = {})
        raise NotImplementedError
      end

      def include_attribute?(record, serializer_params = {})
        return true if @options[:if].blank? && @options[:unless].blank?

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

      def read_for_serialization(record, serializer_params = {}, *args)
        raise NotImplementedError
      end
    end
  end
end
