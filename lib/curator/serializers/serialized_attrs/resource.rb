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
        when 'Attribute', 'Link'
          super(attribute)
        when 'Relation'
          relations[attribute.key] = attribute
        when 'Meta'
          meta[attribute.key] = attribute
        when 'Node'
          nodes[attribute.key] = attribute
        end
      end

      def serializable_attributes_for(attr_set_key)
        case attr_set_key
        when :attributes, :links
          super(attr_set_key)
        when :nodes
          nodes.values
        when :relations
          relations.values
        when :meta
          meta.values
        else
          raise "Unknown Attribute Set Key #{attr_set_key}"
        end
      end

      def read_for_serialization(record, serializer_params = {}, serializable_attributes = [])
        serializable_attributes.reduce(Concurrent::Hash.new) do |res, attribute|
          val = attribute.serialize(record, serializer_params)
          next res if val.blank?

          next res.merge(val) if val.kind_of?(Hash) && attribute.key.blank?

          res.merge(attribute.key => val)
        end
      end

      def attribute_sets
        %i(attributes links meta nodes relations).freeze
      end
    end
  end
end
