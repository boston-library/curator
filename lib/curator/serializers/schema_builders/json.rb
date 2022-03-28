# frozen_string_literal: true

module Curator
  module Serializers
    module SchemaBuilders
      class JSON
        include Alba::Resource

        on_error :ignore

        private

        def converter
          super >> proc { |hash| deep_format_and_compact(hash) }
        end

        #Removes blank values and formats time ActiveSupport::TimeWithZone values to iso8601
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
