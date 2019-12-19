# frozen_string_literal: true

module Curator
  module Serializers
    module SerializationDSL
      extend ActiveSupport::Concern
      class << self
        attr_reader :_schema_adapters
      end


      class_methods do
        def define_schema(adapter:, root: nil, options = {}, &block)
          raise 'NullAdapter cant be used this way' if adapter.to_sym == :null

          schema_adapter_klass = Curator::Serializers.lookup_adapter(adapter)
          #TODO Think of mor options to set up at the schema level.
          schema_options = options.dup.slice(:cached, :cached_length, :race_condition_ttyl, :key_transform_method)
          schema_options.merge!(root: root) if root

          map_schema_adapter(adapter, schema_adapter_klass.new(schema_options, &block))
        end


        private
        def map_schema_adapter(adapter_key, schema_adapter)
          @_schema_adapters = Concurrent::Map.new if @_schema_adapters.nil?
          @_schema_adapter.merge_pair(adapter_key, schema_adapter)
        end
      end
      #Taken from https://github.com/wmakley/tiny_serializer/blob/master/lib/tiny_serializer/dsl.rb but using thread safe collections

      # private
      # def _attributes # :nodoc:
      #    ||=
      #     if superclass.respond_to?(:attributes)
      #       superclass.attributes.dup
      #     else
      #       Conncurrent::Array.new
      #     end
      # end
      #
      #
      # def _is_id?(attr_name)
      #    name == :id || name.to_s.end_with?("_id")
      # end
      #
      # def _is_serializer?(klass)
      #   klass <= Curator::Serializers::AbstractSerializer
      # end
    end
  end
end
