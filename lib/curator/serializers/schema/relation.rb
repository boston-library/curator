# frozen_string_literal: true

module Curator
  module Serializers
    class Relation < Attribute
      attr_reader :serializer

      def initialize(key:, serializer_klass:, options: {})
        @key = key
        @options = options
        @serializer = serializer_klass_for(serializer_klass)
      end
      # You can only add links in this case. everything else is delegated to the relations serializer
      # TODO: Add ability to pass custom root in options
      def read_for_serialization(record, serializer_params = {})
        return if record.blank?

        relation_record = record.public_send(key)
        adapter_key = serializer_params.dup.fetch(:adapter_key, :null)
        adapter_key = :null if relation_record.blank?

        serializer_instance = build_serializer_instance(relation_record, adapter_key, serializer_params)
        serializer_instance.serializable_hash
      end

      def include_value?(record, serializer_params = {})
        super(record, serializer_params.dup.except(:fields)) && include_relation?(serializer_params.dup)
      end

      def include_relation?(serializer_params = {})
        return true if serializer_params.dup.fetch(:included, nil).blank?

        serializer_params.dup.fetch(:included).include?(key)
      end

      private

      def build_serializer_instance(relation_record, adapter_key, serializer_params = {})
        serializer.new(relation_record, adapter_key, serializer_params.dup.merge(adapter_key: adapter_key, for_relation: true))
      end

      def serializer_klass_for(serializer_klass)
        s_klass = serializer_klass.is_a?(String) ? serializer_klass.safe_constantize : serializer_klass

        raise "Invalid Serializer Class #{s_klass}" if s_klass.blank?

        raise "Serializer #{s_klass} does not inherit from Curator::Serializers::AbstractSerializer!" unless s_klass <= Curator::Serializers::AbstractSerializer

        s_klass
      end
    end
  end
end
