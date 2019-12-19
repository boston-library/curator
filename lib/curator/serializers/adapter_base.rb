# frozen_string_literal: true

module Curator
  module Serializers
    class AdapterBase
      extend Forwardable
      attr_reader :schema

      def_delegators :@schema, :attribute, :attributes, :node, :meta, :link, :has_one, :belongs_to, :has_many
      def initialize(options={}, &block)
        @schema = Curator::Schema.new(root: noot)
      end

      #Once the relevant schema is collected you can update the hash output to any format you want
      def serializable_hash(_record, _serializer_params = {})
        raise 'Not Implmented'
      end
    end
  end
end
