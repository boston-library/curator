# frozen_string_literal: true

module Curator
  module Serializers
    class JSONAdapter < AdapterBase
      def serializable_hash(record, serializer_params = {})
        serialized_result = schema.serialize(record, serializer_params.dup.merge(adapter_key: :json))

        # NOTE: Needed a way to return the base serialize  result from the schema for the relatiosn before formatting
        # This option is passed in for the relation facet class on read_for_serialization
        # Therefore you should never have to set this from the serializer class never
        # Or when building the schema
        return serialized_result if serializer_params.dup.fetch(:for_relation, false)

        serialized_result = format_serialized_result(serialized_result.deep_dup)

        return serialized_result if root.blank?

        Concurrent::Hash[run_root_key_transform(record), serialized_result.deep_dup]
      end

      def render(record, serializer_params = {})
        Oj.dump(serializable_hash(record, serializer_params.dup))
      end

      protected

      def format_serialized_result(serialized_result)
        return format_serialized_hash(serialized_result.deep_dup) if serialized_result.is_a?(Hash)

        return format_serialized_array(serialized_result.deep_dup) if serialized_result.is_a?(Array)

        Concurrent::Hash.new
      end

      def format_serialized_array(serialized_array)
        serialized_array.reduce(Concurrent::Array.new) do |ret, serialized|
          ret << format_serialized_hash(serialized) if serialized.is_a?(Hash)

          ret << format_serialized_array(serialized) if serialized.is_a?(Array)

          ret
        end
      end

      def format_serialized_hash(serialized_hash)
        serialized_hash.keys.inject(Concurrent::Hash.new) do |out_hash, key|
          next out_hash.merge(key => format_serialized_result(serialized_hash[key].deep_dup)) unless Serializers::Schema::FACET_TYPES.include?(key)

          case key
          when :attributes
            out_hash.merge(serialized_hash[key].dup)
          when :links, :meta
            out_hash.merge(key => serialized_hash[key].dup)
          when :relations, :nodes
            out_hash.merge(format_serialized_hash(serialized_hash[key].deep_dup))
          else
            next out_hash
          end
        end.as_json
      end
    end
  end
end
