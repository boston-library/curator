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

        def deep_compact(hash)
          hash.map do |key,value|
            value = deep_compact(value) if value.is_a?(Hash)

            [key, value]
          end.to_h.compact_blank
        end
      end
    end
  end
end
