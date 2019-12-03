# frozen_string_literal: true

module Curator
  module Serializers
    class Resource < Node
      attr_reader :meta, :nodes, :relations

      def initialize(*args)
        super
        @attributes = Concurrent::Hash.new
        @meta = Concurrent::Hash.new
        @links = Concurrent::Hash.new
        @nodes = Concurrent::Hash.new
        @relations = Concurrent::Hash.new
      end


      def add_serializable_attr(attribute)
        attr_type = attribute.class.to_s.demodulize
        case attr_type
        when 'Attribute', 'Link', 'Relation'
          super(attribute)
        when 'Meta'
          meta[attribute.key] = attribute
        when 'Node'
          nodes[attribute.key] = attribute
        end
      end

      def serialize(record, serializer_params = {})
        return if record.blank?
        serialized_object = Concurrent::Hash.new
        attribute_sets.each do |attr_set_key|
          serialized_object.merge!(attr_set_key => serialize_attr_set(record, serializable_attributes_for(attr_set_key), serialization_params))
        end
        serialized_object
      end

      def serializable_attributes_for(attr_set_key)
        case attr_set_key
        when :attributes, :links, :relations
          super(attr_set_key)
        when :nodes
          nodes.values
        when :meta
          meta.values
        else
          raise "Unknown Attribute Set Key #{attr_set_key}"
        end
      end

      def serialize_attr_set(record, serializable_attributes = [], serialization_params = {})
        serializable_attributes.reduce(Concurrent::Hash.new) do |res, attribute|
          val = attribute.serialize(resource, serialization_params)
          next res if val.blank?

          res.merge!(attribute.key => val)
        end
      end

      def attribute_sets
        %i(attributes links meta nodes relations).freeze
      end
    end
  end
end
