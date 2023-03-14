# frozen_string_literal: true

module Curator
  module Serializers
    module SchemaBuilders
      class JSON
        # Base builder class for serializing data to JSON.
        # See https://github.com/okuramasafumi/alba/blob/v1.6.0/README.md for information on DSL methods and class functionality
        include Alba::Resource
        include SchemaBuilders::AlbaJsonHelpers

        on_error :ignore
      end
    end
  end
end
