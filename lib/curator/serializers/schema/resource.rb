# frozen_string_literal: true

module Curator
  module Serializers
    class Resource < Node
      attr_reader

      def initialize(*args)
        super

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

      def attribute_sets
        %i(attributes links meta nodes relations).freeze
      end
    end
  end
end
