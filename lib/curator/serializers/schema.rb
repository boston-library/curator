# frozen_string_literal: true

module Curator
  module Serializers
    class Schema

      class Facet < Struct.new(:type, :schema_attribute, keyword_init: true)
        def initialize(**kwargs)
          super(**kwargs)
          raise "Unknown Facet Type #{self.type}" unless %i(attribute link meta node relation).include?(self.type)
          freeze
        end

        def to_h
          Concurrent::Hash[self.type, Concurrent::Hash[self.schema_attribute.key, self.schema_attribute]]
        end
      end

      attr_reader :root, :facets, :options

      def initialize(root: nil, options: {})
        @root = root
        @facets = Concurrent::Array.new
      end

      def attribute(key:, **options, &block)
        add_facet(type: :attribute, schema_attribute: Attribute.new(key: key, method: block || key, options: options) )
      end

      def attributes(*attribute_keys, **options)
        attribute_keys.each { |attribute_key| attribute(attribute_key, options) }
      end

      def link(key:, **options, &block)
        add_facet(type: :link, schema_attribute: Link.new(key: key, method: block || key, options: options) )
      end

      def meta(key:, &block)
        add_facet(type: :meta, schema_attribute: Meta.new(key: key, method: block))
      end

      def node(key: nil, **options, &block)
        add_facet(type: :node, schema_attribute: Node.new(key: root, options: options, &block) )
      end

      def relation(key:, **options, &block)
      end

      alias :has_one :relation
      alias :has_many :relation
      alias :belongs_to :relation

      def facet_groups
        @facets.group_by(&:type).reduce(Concurrent::Hash.new) { |ret, (k,v)|  ret.merge(k => v.map { |i| i.to_h.delete(k) }) }
      end
      #TODO - FIgure out a way to add links and meta passed in from ther serializer params too

      def serialize(record, serializer_params = {})
        return Concurrent::Hash.new if record.blank?

        return serialize_each(record, serializer_params) if is_collection?(record)

        grouped_facets.dup.keys.inject(Concurrent::Hash.new) do |res, facet_group|
          res.merge(serialize_facets(facet_group, record, serializer_params))
        end
      end
      #
      def serialize_each(records, serializer_params = {})
        records.inject(Concurrent::Array.new) do |arr, record|
          arr.concat(serialize(record, serializer_params))
        end
      end

      def serialize_facets(facet_group, record, serializer_params = {})
        grouped_facets.dup.slice(facet_group).values.reduce(Concurrent::Hash[facet_group, Concurrent::Hash.new]) do |res, facet|
          next res unless facet.include_value?(record, serializer_params)

          val = facet.serialize(record, serializer_params)
          next res if val.blank?

          res[facet_group].merge(attribute.key => val)
        end
      end

      private
      def is_collection?(record)
        record.kind_of?(ActiveRecord::Associations::CollectionProxy) || record.kind_of?(Array)
      end

      def add_facet(type:, schema_attribute:)
        @facets.concat(Facet.new(type: type, schema_attribute: schema_attribute))
      end

    end
  end
end
