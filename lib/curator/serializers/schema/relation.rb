# frozen_string_literal: true

module Curator
  module Serializers
    class Relation < Node
      attr_accessor :serializer

      #Method should be has_one or has_many
      def initialize(root: nil, options: {}, serializer:)
        super
        @serializer = serializer
      end

      #You can only add links in this case. everything else is delegated to the relations serializer
      def add_serializable_attr(attribute)
        attr_type = attribute.class.to_s.demodulize.downcase.to_sym
        raise "Unsupported Attribute Type For Node #{attr_type}!" if %i(node ).include?(attr_type)
        attributes.fetch(attr_type) { |key| attributes[key].merge!(attribute.key => attribute) }
      end

      def serialize(record, serializer_params = {})
        relation_record = record.public_send(:root_key)
        serializer
      end

      def include_value?(record, serializer_params = {})
        super(record, serializer_params) && include_relation?(serializer_params)
      end

      def include_relation?(serializer_params = {})
        return true if serializer_params[:include].blank?
        serializer_params.include?(key)
      end
    end
  end
end
