# frozen_string_literal: true

module Curator
  module Serializers
    class Relationship < Node
      attr_reader :serializer

      #Method should be has_one or has_many
      def initialize(key: nil, method: nil, options: {}, serializer:)
        super
        @serializer = serializer
      end

      #You can only add links in this case. everything else is delegated to the relations serializer
      def add_serializable_attr(attribute)
        attr_type = attribute.class.to_s.demodulize
        case attr_type
        when 'Link'
          links[attribute.key] = attribute
        else
          raise "Unsupported attribute type for Relation #{attr_type}"
        end
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
