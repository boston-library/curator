# frozen_string_literal: true

module Curator
  module Serializers
    class Adapter
      attr_reader :schema, :options
      def initialize(schema:)
        @schema = schema
      end

      def serializable_hash(record, serializer_options = {})
        raise 'Not Implmented'
      end

    end
  end
end
