# frozen_string_literal: true

module Curator
  module Serializers
    module SchemaBuilders
      module AlbaJsonHelpers
        extend ActiveSupport::Concern

        included do
          include InstanceMethods
        end

        module InstanceMethods
          def format_time_iso8601(time)
            time.iso8601 if time.respond_to?(:iso8601)
          end

          def select(_key, val)
            val.respond_to?(:empty?) ? !val.empty? : !val.nil?
          end

          def serializable_hash
            Alba.collection?(@object) ? deep_collection_compact(super) : deep_compact(super)
          end

          private

          def deep_collection_compact(array)
            array.reduce([]) do |ret, hash|
              ret << deep_compact(hash)
              ret
            end.compact_blank
          end

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
end
