# frozen_string_literal: true

module Curator
  module Serializers
    class Attribute < SerializedAttr
      def serialize(record, serialization_params = {})
        return nil unless include_attribute?(record, serialization_params)
        read_for_serialization(record, serialization_params)
      end

      #Attributes cna be read as blocks and public mehods but also read with read attribute for serialization method
      def read_for_serialization(record, serializer_params = {}, *args)
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
