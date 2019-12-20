# frozen_string_literal: true

module Curator
  module Serializers
    class AdapterBase
      extend Forwardable
      attr_reader :schema

      def_delegators :@schema, :root, :attribute, :attributes, :node, :meta, :link, :has_one, :belongs_to, :has_many
      def initialize(options={}, &block)
        @schema = Curator::Schema.new(root: options.delete(:root), options: options)
        instance_eval(&block)
      end
      #Once the relevant schema is collected you can update the hash output to any format you want
      def serializable_hash(_record, _serializer_params = {})
        raise 'Not Implmented'
      end

      def render(_record, _serializer_params)
        raise 'Not Implemented'
      end
    end
  end
end
