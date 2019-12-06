# frozen_string_literal: true

module Curator
  module Serializers
    class Adapter
      extend Forwardable
      attr_reader :schema
      def_delegator :@schema, :add_serializable_attr, :add_attr_to_schema
      def_delegator :@schema, :options, :schema_options
      def initialize(schema)
        @schema = schema
      end

      #Once the relevant schema is collected you can update the hash output to any format you want
      def serializable_hash(_record, _serializer_options = Concurrent::Hash.new)
        raise 'Not Implmented'
      end
    end
  end
end
