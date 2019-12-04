# frozen_string_literal: true

module Curator
  module Serializers
    class Meta < Attribute
      def include_attribute?(_record, _serializer_params = {})
        true
      end

      #Only public methods and blocks can generate meta
      def read_for_serialization(record, serializer_params = {})
        if method.is_a?(Proc)
          method.arity.abs == 1 ? method.call(record) : method.call(record, serializer_params)
        else
          record.public_send(method)
        end
      end
    end
  end
end
