# frozen_string_literal: true

module Curator
  module Serializers
    class Node < Attribute
      attr_reader :attributes, :links

      def initialize(key: nil, method: nil, options: {})
        super
        @attributes = Concurrent::Hash.new
        @links = Concurrent::Hash.new
      end

      def add_serializable_attr(attribute)
        attr_type = attribute.class.to_s.demodulize
        case attr_type
        when 'Attribute'
          attributes[attribute.key] = attribute
        when 'Link'
          links[attribute.key] = attribute
        end
      end

      def serialize(record, serializer_params = {})
        return if record.blank?
        attribute_sets.inject(Concurrent::Hash.new) do |obj_hash, attr_set_key|
          obj_hash.merge(attr_set_key => read_attribute_for_serialization(record, serialization_params, serializable_attributes_for(attr_set_key)))
        end
      end

      def serializable_attributes_for(attr_set_key)
        case attr_set_key
        when :attributes
          attributes.values
        when :links
          links.values
        else
          raise "Unknown Attribute Set Key #{attr_set_key}"
        end
      end

      #TODO - FIgure out a way to add links and meta passed in from ther serializer params too
      def read_for_serialization(record, serializer_params = {}, serializable_attributes = [])
        serializable_attributes.reduce(Concurrent::Hash.new) do |res, attribute|
          val = attribute.serialize(record, serializer_params)
          next res if val.blank?

          res.merge(attribute.key = val)
        end
      end

      def attribute_sets
        %i(attributes links).freeze
      end
    end
  end
end
