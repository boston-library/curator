# frozen_string_literal: true

module Curator
  module Serializers
    class Relation < Node
      attr_reader :serializer

      #Method should be has_one or has_many
      def initialize(key:, options: {}, serializer:)
        super(key: key, options: options)
        @serializer = serializer
      end

      #You can only add links in this case. everything else is delegated to the relations serializer

      def serialize(record, serializer_params = {})
        relation_record = record.public_send(:root_key)
        serializer
      end

      def include_value?(record, serializer_params = {})
        super(record, serializer_params) && include_relation?(serializer_params)
      end

      def include_relation?(serializer_params = {})
        return true if serializer_params[:included].blank?
        serializer_params.include?(key)
      end
    end
  end
end
