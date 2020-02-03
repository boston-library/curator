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

      def initialize_dup(source)
        @schema = source.schema.deep_dup
        super
      end

      protected

      def run_key_transform(key, pluralize = false)
        return if key.to_s.blank?

        pluralize ? key.to_s.pluralize.public_send(schema.key_transform_method) : key.to_s.public_send(schema.key_transform_method)
      end

      def run_root_key_transform(record)
        return if root.to_s.blank?

        run_key_transform(root.dup, schema.is_collection?(record))
      end
    end
  end
end
