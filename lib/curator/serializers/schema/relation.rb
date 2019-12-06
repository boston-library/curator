# frozen_string_literal: true

module Curator
  module Serializers
    class Relation < Node
      attr_accessor :serializer

      #Method should be has_one or has_many
      def initialize(root_key: nil, options: {}, serializer:)
        super
        @serializer = serializer
      end

      #You can only add links in this case. everything else is delegated to the relations serializer
      def add_serializable_attr(attribute)
      end

      def read_for_serialization(record, serializer_params = {})
        super(record, serializer_params)
      end

      def include_attribute?(record, serializer_params = {})
        super(record, params) && include_relation?(serializer_params)
      end

      def include_relation?(serializer_params = {})
        return true if serializer_params[:include].blank?

        serializer_params.include?(key)
      end

      def attribute_sets
        %i(links).freeze
      end
    end
  end
end
