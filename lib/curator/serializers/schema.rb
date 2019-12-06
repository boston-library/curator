# frozen_string_literal: true

module Curator
  module Serializers
    class Schema
      attr_reader :attributes, :options
      def initialize
        @options = Concurrent::Hash.new
        @attributes = Concurrent::Hash.new {|h, k| h[k] = Concurrent::Hash.new }
      end

      def add_serializable_attr(attribute)
        attr_type = attribute.class.to_s.demodulize.downcase.to_sym
        attributes.fetch(attr_type) { |key| attributes[key].merge!(attribute.key => attribute) }
      end

      #TODO - FIgure out a way to add links and meta passed in from ther serializer params too
      def serialize(record, serializer_params = {}, serializable_attributes = [])
        attributes.inject({}) do |attribute_type, attrs|

        end
      end

      def is_collection?(record)
      end
    end
  end
end
