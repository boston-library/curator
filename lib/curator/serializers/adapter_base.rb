# frozen_string_literal: true

module Curator
  module Serializers
    class AdapterBase
      extend Forwardable
      attr_reader :schema

      def_delegators :schema, :root, :attribute, :attributes, :node, :meta, :link, :has_one, :belongs_to, :has_many
      def initialize(options = {}, &block)
        @schema = Curator::Serializers::Schema.new(root: options.delete(:root), options: options.dup)
        instance_eval(&block)
      end

      # NOTE: Once the relevant schema is collected you can update the hash output to any format you want
      def serializable_hash(_record = nil, _serializer_params = {})
        raise 'Not Implemented'
      end

      def render(_record = nil, _serializer_params = {})
        raise 'Not Implemented'
      end

      protected

      def transformed_root_key(record)
        return if root.blank?

        return root unless schema.is_collection(record)

        root.to_s.pluralize.to_sym
      end
    end
  end
end
