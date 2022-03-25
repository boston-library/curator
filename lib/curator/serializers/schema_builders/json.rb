# frozen_string_literal: true

module Curator
  module Serializers
    module SchemaBuilders
      class JSON
        include Alba::Resource

        on_error :ignore

        private

        def converter
          super >> proc { |hash| deep_compact(hash) }
        end

        #Removes blank values
        def deep_compact(hash)
          hash.reduce({}) do |ret, (key, value)|
            new_val = case value
                      when Hash
                        deep_compact(value)
                      when Array
                        value.map { |v| v.is_a?(Hash) ? deep_compact(v) : v }
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
