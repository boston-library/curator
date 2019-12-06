# frozen_string_literal: true

module Curator
  module Serializers
    #Used for attr_json models and relationships
    class Node < Schema
      def initialize(root_key: nil, options: Concurrent::Hash.new)
        raise "Root Key must be defined on Nested Node" if root_key.blank? #root key is also a method
        super
      end

      def add_serializable_attr(attribute)
        attr_type = attribute.class.to_s.demodulize.downcase.to_sym
        raise "Unsupported Attribute Type For Node #{attr_type}!" unless %i(attribute link meta).include?(attr_type)
        attributes.fetch(attr_type) { |key| attributes[key].merge!(attribute.key => attribute) }
      end

      def serialize(record, serializer_params = Concurrent::Hash.new)
        serialized_object = Concurrent::Hash.new
        node_val = record.public_send(root_key)
      end

      def include_node?(record, serializer_params = Concurrent::Hash.new)
        record.respond_to?(root_key)
      end
    end
  end
end
