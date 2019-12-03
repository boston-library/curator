# frozen_string_literal: true

module Curator
  module Serializers
    class NullResource < Resource
      def serialize
        nil
      end

      def include_attribute?(record, serialization_params = {})
        false
      end

      def read_attribute_for_serialization(record, serialization_params = {})
        nil
      end
    end
  end
end
