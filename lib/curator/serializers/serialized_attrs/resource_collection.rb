# frozen_string_literal: true


module Curator
  module Serializers
    class Collection < SerializedAttr

      def serialize(resources, serializer_params = {})
        return if resources.blank?
      end

      def included_attribute?(resources, serializer_params = {})
        true
      end

      def read_attribute_for_serialization(resources, serializer_params = {})
      end
    end
  end
end
