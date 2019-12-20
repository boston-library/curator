# frozen_string_literal: true

module Curator
  module Serializers
    class JSONAdapter < AdapterBase

      def serializable_hash(record, serializer_params = {})
        serialized_hash = schema.serialize(record, seralizer_params)
      end

      def render(record, serializer_params = {})
        Oj.dump(serializable_hash(serializer_options))
      end
    end
  end
end
