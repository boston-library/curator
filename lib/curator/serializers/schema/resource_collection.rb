# frozen_string_literal: true


module Curator
  module Serializers
    class ResourceCollection < Relation
      #For Top Level collections of a resource

      def serialize(records, serializer_params = {})
        return if records.blank?

        read_for_serialization(records, serializer_params)
      end

      def include_attribute?(_records, _serializer_params = {})
        true
      end
    end
  end
end
