# frozen_string_literal: true

module Curator
  module Serializers
    class Schema
      attr_reader :root_key, :attributes, :options

      def initialize(root_key: nil, options: Concurrent::Hash.new )
        @options = Concurrent::Hash.new
        @root_key = root_key
        @attributes = Concurrent::Hash.new {|h, k| h[k] = Concurrent::Hash.new }
      end

      def add_serializable_attr(attribute)
        attr_type = attribute.class.to_s.demodulize.downcase.to_sym
        attributes.fetch(attr_type) { |key| attributes[key].merge!(attribute.key => attribute) }
      end

      def add_nesting(node, &block)
        raise "Nested Node requires block!" unless block_given?
        node.instance_eval(&block)
        attributes.fetch(:node) { |key| attributes[key].merge!(node.root_key => node) }
      end

      #TODO - FIgure out a way to add links and meta passed in from ther serializer params too

      def serialize(record, serializer_params = Concurrent::Hash.new)
        return serialize_each(record, serializer_params) if record.present? && is_collection?(record)

        serialized = Concurrent::Hash.new
        return serialized if record.blank?

        serialized.merge!(serialize_attributes(record, serializer_params))
        serialized.merge!(serialize_nodes(record, serializer_params))
        serialized
      end

      def serialize_each(records, serializer_params = Concurrent::Hash.new)
        serialized_objects = records.inject(Concurrent::Array.new) do |arr, record|
          arr << serialize(record, serializer_params)
        end
        return serialized_objects if root_key.blank?
        Concurrent::Hash[root_key.to_s.pluralize.to_sym, serialized_objects]
      end

      def serialize_attributes(record, serializer_params = Concurrent::Hash.new)
        attributes.slice(:attribute).values.reduce(Concurrent::Hash[:attributes, Concurrent::Hash.new]) do |res, attribute|
          next res unless attribute.include_attribute?(record, serializer_params)

          val = attribute.serialize(record, serializer_params)
          next res if val.blank?

          res[:attributes].merge(attribute.key => val)
        end
      end

      def serialize_nodes(record, serializer_params = {})
        attribute.slice(:node).values.reduce(Concurrent::Hash[:nodes, Concurrent::Hash.new]) do |res, node|
          val = node.serialize(record)
          next res if val.blank?

          res[:nodes].merge(node.root_key => val)
        end
      end

      def is_collection?(record)
        record.kind_of?(ActiveRecord::Associations::CollectionProxy) || record.kind_of?(Array)
      end

      protected
      def validate_options!(options)
      end
    end
  end
end
