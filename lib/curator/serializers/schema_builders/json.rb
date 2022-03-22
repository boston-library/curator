# frozen_string_literal: true

module Curator
  module Serializers
    module SchemaBuilders
      class JSON
        include Alba::Resource

        on_error :ignore

        private

        def converter
          super >> proc { |hash| hash.compact }
        end
      end
    end
  end
end
