# frozen_string_literal: true

module Curator
  module Serializers
    class SerializationAdapter
      attr_reader :resource, :options
      def initialize(resource = nil, options: {})
        @resource = resource
        @options = options
      end

      def serializable_hash
        raise 'Not Implmented'
      end
      alias_method :to_hash, :serializable_hash

      def render
        raise 'Not Implmented'
      end
    end
  end
end
