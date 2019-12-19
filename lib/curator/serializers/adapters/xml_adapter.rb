# frozen_string_literal: true

module Curator
  module Serializers
    class XMLAdapter < AdapterBase

      def serializable_hash(record, serializer_options)
      end

      def render
        Ox.dump(serializable_hash)
      end
    end
  end
end
