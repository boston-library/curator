# frozen_string_literal: true

module Curator
  module Serializers
    module SchemaBuilders
      class JSON
        # Base builder class for serializing data to JSON.
        # See https://github.com/okuramasafumi/alba/blob/v1.6.0/README.md for information on DSL methods and class functionality
        include Alba::Resource

        on_error :ignore

        private

        # @returns [Hash] Overrides Alba::Resource#converter
        def converter
          super >> proc { |hash| deep_format_and_compact(hash) }
        end

        # @return [Hash] - Removes blank values and formats time ActiveSupport::TimeWithZone values to iso8601
        def deep_format_and_compact(hash)
          hash.reduce({}) do |ret, (key, value)|
            new_val = case value
                      when Hash
                        deep_format_and_compact(value)
                      when Array
                        value.map { |v| v.is_a?(Hash) ? deep_format_and_compact(v) : v }
                      when ActiveSupport::TimeWithZone
                        value.iso8601
                      else
                        value
                      end
            ret[key] = new_val
            ret
          end.compact_blank
        end
      end
    end
  end
end
