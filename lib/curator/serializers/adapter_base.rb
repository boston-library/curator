# frozen_string_literal: true

module Curator
  module Serializers
    class AdapterBase
      attr_reader :base_builder_class, :schema_builder_class

      def initialize(base_builder_class:)
        @base_builder_class = base_builder_class
      end

      # NOTE: Once the relevant schema is collected you can update the hash output to any format you want
      def serializable_hash(_resource = nil, _params = {})
        raise Curator::Exception::CuratorError, 'Not Implemented'
      end

      def serialize(_resource= nil, _params = {})
        raise Curator::Exception::CuratorError, 'Not Implemented'
      end
    end
  end
end
