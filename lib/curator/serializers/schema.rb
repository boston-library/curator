# frozen_string_literal: true

module Curator
  module Serializers
    class Schema
      # Method to call map const for root key if present
      ROOT_KEY_TRANSFORM_MAPPING = {
        camel: :camelize,
        dash: :dasherize,
        underscore: :underscore,
        default: :underscore
      }.freeze

      FACET_TYPES = %i(attributes links meta nodes relations).freeze

      class Facet < Struct.new(:type, :schema_attribute, keyword_init: true)
        def initialize(**kwargs)
          super(**kwargs)
          raise "Unknown Facet Type #{type}" unless FACET_TYPES.include?(type)

          freeze
        end

        def to_h
          Concurrent::Hash[type, schema_attribute]
        end

        def deep_dup
          super.freeze
        end
      end

      attr_reader :root, :facets, :options

      def initialize(root: nil, options: {})
        @root = root
        @facets = Concurrent::Array.new
        @options = options
      end

      def update_root!(root = nil)
        @root = root
      end

      def initialize_dup(source)
        @facets = source.facets.inject(Concurrent::Array.new) { |res, facet| res << facet.deep_dup }
        super
      end

      # DSL METHODS
      def attribute(key, **opts, &block)
        add_facet(type: :attributes, schema_attribute: Attribute.new(key: key, method: block || key, options: opts))
      end

      def attributes(*attribute_keys, **opts)
        attribute_keys.each { |attribute_key| attribute(attribute_key, **opts) }
      end

      def link(key, **opts, &block)
        add_facet(type: :links, schema_attribute: Link.new(key: key, method: block || key, options: opts))
      end

      def meta(key, &block)
        add_facet(type: :meta, schema_attribute: Meta.new(key: key, method: block))
      end

      def node(key, **opts, &block)
        add_facet(type: :nodes, schema_attribute: Node.new(key: key, options: opts.merge(options.dup), &block))
      end

      def relation(key, serializer:, **opts, &block)
        add_facet(type: :relations, schema_attribute: Relation.new(key: key, serializer_klass: serializer, options: opts.merge(options.dup), &block))
      end

      alias_method :has_one, :relation
      alias_method :has_many, :relation
      alias_method :belongs_to, :relation

      # UTIL/HELPER METHODS
      def facet_groups
        @facets.group_by(&:type).reduce(Concurrent::Hash.new) { |ret, (type, f)| ret.merge(type => f.flat_map { |i| i.to_h.values }) }
      end

      def is_collection?(record)
        record.kind_of?(ActiveRecord::Relation) || record.kind_of?(Array)
      end

      def key_in_group?(facet_group, key)
        facet_groups.reduce(Concurrent::Hash.new) do |ret, (type, facets)|
          ret.merge(type => facets.map(&:key))
        end.fetch(facet_group, []).include?(key)
      end

      def key_transform_method
        method = options.fetch(:key_transform_method, ROOT_KEY_TRANSFORM_MAPPING[:default])
        raise "Unknown key transform method #{method}" unless ROOT_KEY_TRANSFORM_MAPPING.key?(method)

        ROOT_KEY_TRANSFORM_MAPPING[method]
      end

      def cache_enabled?
        options.fetch(:cache_enabled, false)
      end

      def cache_options
        options.fetch(:cache_options, {})
      end

      def serialize(record, serializer_params = {})
        return Concurrent::Hash.new if record.blank?

        return serialize_each(record, serializer_params) if is_collection?(record)

        if cache_enabled?
          serialized_result = with_cache(record) do
            facet_groups.dup.keys.inject(Concurrent::Hash.new) do |res, facet_group|
              res.merge(serialize_facets(facet_group, record, serializer_params.dup))
            end
          end
        else
          serialized_result = facet_groups.dup.keys.inject(Concurrent::Hash.new) do |res, facet_group|
            res.merge(serialize_facets(facet_group, record, serializer_params.dup))
          end
        end
        serialized_result
      end

      def serialize_each(records, serializer_params = {})
        records.inject(Concurrent::Array.new) do |ret, record|
          ret << serialize(record, serializer_params.dup)
        end
      end

      protected

      def serialize_facets(facet_group, record, serializer_params = {})
        serialized_facet = Concurrent::Hash.new
        serialized_facet[facet_group] = facet_groups.dup.slice(facet_group).values.flatten.reduce(Concurrent::Hash.new) do |res, facet|
          next res unless facet.include_value?(record, serializer_params.dup)

          val = facet.serialize(record, serializer_params.dup)
          next res if val.blank?

          res.merge(facet.key => val)
        end
        serialized_facet
      end

      def with_cache(record)
        cache_key_method = cache_options.fetch(:cache_key_method, :cache_key)
        cached_length = cache_options.fetch(:cached_length, 5.minutes)
        race_condition_ttl = cache_options.fetch(:race_condition_ttl, 5.seconds)

        Rails.cache.fetch(record.public_send(cache_key_method), expires_in: cached_length, race_condition_ttl: race_condition_ttl) do
          yield
        end
      end

      private

      # def parse_val(val)
      #   return if val.blank?
      #
      #   return val if !val.is_a?(Array) && !val.is_a?(Hash)
      #
      #   return val.inject(Concurrent::Hash.new) do |ret, (key, val)|
      #     pval = parse_val(val)
      #
      #     next ret if pval.blank?
      #
      #     ret.merge(key => pval)
      #   end if val.is_a?(Hash)
      #
      #   val.inject(Concurrent::Array.new) do |ret, el|
      #     pval = parse_val(el)
      #
      #     next ret if pval.blank?
      #
      #     ret << pval
      #   end
      # end

      def add_facet(type:, schema_attribute:)
        warn("#{schema_attribute.key} is already mapped to group #{type} using falling back to previous value") if key_in_group?(type, schema_attribute.key)
        @facets << Facet.new(type: type, schema_attribute: schema_attribute) unless key_in_group?(type, schema_attribute.key)
      end
    end
  end
end
