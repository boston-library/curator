# frozen_string_literal: true

module Curator
  module Serializers
    class XMLAdapter < AdapterBase
      #Note XML Adapters don't include meta/link facets
      def_delegators :@schema, :attribute, :attributes, :node, :has_one, :belongs_to, :has_many

      def serializable_hash(record, serializer_options = {})
        serialized_hash = schema.serialize(record, serializer_options)
      end

      def render(record, serializer_options = {})
        Ox.dump(serializable_hash(record, serializer_options))
      end
    end
  end
end
