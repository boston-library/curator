# frozen_string_literal: true

module Curator
  module Serializers
    class JSONAdapter < AdapterBase
      def serializable_hash(record, serializer_params = {})
        serialized_result = schema.serialize(record, serializer_params.dup.reverse_merge!(adapter_key: :json))

        if serialized_result.is_a?(Hash)
          serialized_result = format_serialized_hash(serialized_result.deep_dup).freeze
        elsif serialized_result.is_a?(Array)
          serialized_result = serialized_result.map { |sr| format_serialized_hash(sr) }.freeze
        end

        return serialized_result if root.blank?

        Hash[run_root_key_transform(record), serialized_result].freeze
      end

      def render(record, serializer_params = {})
        Oj.dump(serializable_hash(record, serializer_params.dup))
      end

      protected

      def format_serialized_hash(serialized_hash)
        serialized_hash.keys.inject({}) do |out_hash, key|
          next out_hash.merge(key => format_serialized_hash(serialized_hash[key].deep_dup.to_h)) unless Serializers::Schema::FACET_TYPES.include?(key)

          case key
          when :attributes
            out_hash.merge(serialized_hash[key].dup.to_h)
          when :links, :meta
            out_hash.merge(key => serialized_hash[key].dup.to_h)
          when :relations, :nodes
            out_hash.merge(format_serialized_hash(serialized_hash[key].deep_dup.to_h))
          else
            next out_hash
          end
        end.deep_transform_keys! { |key| run_key_transform(key).to_s }
      end
    end
  end
end
