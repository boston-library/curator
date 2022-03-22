# frozen_string_literal: true

module Curator
  module Serializers
    class NullAdapter < AdapterBase
      def initialize(*)
        @schema_builder_class = nil
      end

      def serializable_hash(resource = nil, _params = {})
        return [] if record.is_a?(Enumerable)

        {}
      end

      def serialize(record = nil, params = {})
        serializable_hash(record, params)
      end
    end
  end
end
