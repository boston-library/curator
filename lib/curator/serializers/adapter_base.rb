# frozen_string_literal: true

module Curator
  module Serializers
    class AdapterBase
      attr_reader :base_builder_class, :schema_builder_class
      # Base class for Adapters
      # @param :base_builder_class [Class defined in SchemaBuilders module] class to inherit from. NOTE: this should have a builder DSL defined
      # @return [Curator::Serializers::AdapterBase] instance - WARNING: This is an abstract class and should not be used directly
      def initialize(base_builder_class:)
        @base_builder_class = base_builder_class
      end

      # NOTE: Once the relevant schema is collected you can update the hash output to any format you want
      def serializable_hash(_resource = nil, _params = {})
        raise Curator::Exceptions::CuratorError, 'Not Implemented'
      end

      def serialize(_resource= nil, _params = {})
        raise Curator::Exceptions::CuratorError, 'Not Implemented'
      end
    end
  end
end
