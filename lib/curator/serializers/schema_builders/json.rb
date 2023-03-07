# frozen_string_literal: true

module Curator
  module Serializers
    module SchemaBuilders
      class JSON
        # Base builder class for serializing data to JSON.
        # See https://github.com/okuramasafumi/alba/blob/v1.6.0/README.md for information on DSL methods and class functionality
        include Alba::Resource

        on_error :ignore

        def format_time_iso8601(time)
          time.iso8601 if time.respond_to?(:iso8601)
        end

        def select(_key, val)
          val.respond_to?(:empty?) ? !val.empty? : !val.nil?
        end
      end
    end
  end
end
