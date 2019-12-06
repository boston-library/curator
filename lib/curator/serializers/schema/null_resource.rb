# frozen_string_literal: true

module Curator
  module Serializers
    class NullResource < Node
      def serialize
        nil
      end

      def include_attribute?(_record, _serializer_params = {})
        false
      end

      def read_for_serialization(_record, _serializer_params = {})
        nil
      end
    end
  end
end
