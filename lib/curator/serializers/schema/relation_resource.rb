# frozen_string_literal: true

module Curator
  module Serializers
    class RelationCollection < Relation

      def serialize(record, serializer_params = {})
        return if record.blank? || record.public_send(method).blank?
        read_for_serialization(record, serializer_params) if include_attribute?(record, serializer_params)
      end

      def read_for_serialization(record, serializer_params = {})
        serializable_object = super(record, serializer_params)
        relation = record.public_send(method)
        return serializable_object if relation.blank?

        serializable_object.merge(key => serializer.serialize(relation, serializer_params)) if relation
      end
    end
  end
end
