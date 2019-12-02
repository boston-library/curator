# frozen_string_literal: true

module Curator
  module Serializers
    module SerializationDSL
      module AdapterDSL
        ADAPTER_THREAD_KEY = 'current_curator_serializer_adapter'
        DEFAULT_ADAPTER_KEY = :json


        private
        def _adapter_for(key = DEFAULT_ADAPTER_KEY)
          _adapters[key]
        end

        def _adapters
          Thread.current[ADAPTER_THREAD_KEY] ||= Curator::Serializer::AdapterMap.new
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
