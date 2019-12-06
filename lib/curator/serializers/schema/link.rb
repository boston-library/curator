# frozen_string_literal: true

module Curator
  module Serializers
    class Link < Attribute
      #Only public methods and blocks can generate links

      def read_for_serialization(record, serializer_params = Concurrent::Hash.new )
        if method.is_a?(Proc)
          method.arity.abs == 1 ? method.call(record) : method.call(record, serializer_params)
        else
          record.public_send(method)
        end
      end

      def include_attribute?(record, serializer_params = Concurrent::Hash.new )
        conditions_passed?(record, serializer_params)
      end
    end
  end
end
