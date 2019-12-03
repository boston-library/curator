# frozen_string_literal: true

module Curator
  module Serializers
    class Relation < Node
      attr_accessor :serializer

      def initialize(key: nil, method: nil, options: {}, serializer:)
        super
        @serializer = serializer
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

      def include_attribute?(resource, serializer_params = {})
        super(resource, params) && include_relation?(params)
      end

      def include_relation?(serializer_params = {})
        return true if serializer_params[:include].blank?
      end
    end
  end
end
