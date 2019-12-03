# frozen_string_literal: true

module Curator
  module Serializers
    class Node < Attribute
      attr_reader :attributes, :links, :relations

      def initialize(key:, *args)
        super
        @attributes = Concurrent::Hash.new
        @links = Concurrent::Hash.new
        @relations = Concurrent::Hash.new
      end

      def add_serializable_attr(attribute)
        attr_type = attribute.class.to_s.demodulize
        case attr_type
        when 'Attribute'
          attributes[attribute.key] = attribute
        when 'Relation'
          relations[attribute.key] = attribute
        when 'Link'
          links[attribute.key] = attribute
        end
      end

      def serialize(record, serializer_params = {})
        return if record.blank?
        serialized_object = Concurrent::Hash.new
        attribute_sets.each do |attr_set_key|
          serialized_object.merge!(attr_set_key => read_attribute_for_serialization(record, serialization_params, serializable_attributes_for(attr_set_key)))
        end
        serialized_object
      end

      def serializable_attributes_for(attr_set_key)
        case attr_set_key
        when :attributes
          attributes.values
        when :relations
          relations.values
        when :links
          links.values
        else
          raise "Unknown Attribute Set Key #{attr_set_key}"
        end
      end

      def read_attribute_for_serialization(record, serializer_params = {}, serializable_attributes = [])
        serializable_attributes.reduce(Concurrent::Hash.new) do |res, attribute|
          val = attribute.serialize(resource, serializer_params)
          next res if val.blank?

          res.merge!(attribute.key = val)
        end
      end

      def attribute_sets
        %i(attributes links relations).freeze
      end
    end
  end
end
