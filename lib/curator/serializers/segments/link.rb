# frozen_string_literal: true

module Curator
  module Serializers
    class Link
      protected
      def read_attribute_for_serialization(record, serialization_params)
        if method.is_a?(Proc)
          method.arity.abs == 1 ? method.call(record) : method.call(record, serialization_params)
        else
          record.public_send(method)
        end
      end
    end
  end
end
