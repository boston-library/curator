# frozen_string_literal: true

module Curator
  module Serializers
    class JSONAdapter < AdapterBase
      def serializable_hash(record, serializer_params = {})
        schema_hash = schema.serialize(record, serializer_params.dup.reverse_merge!(adapter_key: :json))
        awesome_print schema_hash
        schema_hash
      end

      def render(record, serializer_params = {})
        Oj.dump(serializable_hash(record, serializer_params.dup))
      end
    end
  end
end
