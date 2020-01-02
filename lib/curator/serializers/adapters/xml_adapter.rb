# frozen_string_literal: true

module Curator
  module Serializers
    class XMLAdapter < AdapterBase
      # NOTE XML Adapters don't include meta/link facets
      def_delegators :@schema, :attribute, :attributes, :node, :has_one, :belongs_to, :has_many

      def serializable_hash(record, serializer_params = {})
        schema.serialize(record, serializer_params.dup.reverse_merge!(adapter_key: :xml))
      end

      def render(record, serializer_params = {})
        Ox.dump(serializable_hash(record, serializer_params.dup))
      end
    end
  end
end
