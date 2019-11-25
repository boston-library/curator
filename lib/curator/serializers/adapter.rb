# frozen_string_literal: true

module Curator
  module Serializers
    class Adapter
      def initialize(record_view_hash, serializer_options = {})
        @record_view_hash = record_hash
        @serializer_options = {}
      end

      def serializable_hash(record_hash, options={})
      end

      def as_json(options = {})
        serializable_hash(options)
      end

      def to_json(options = {})
        Oj.dump(serializable_hash(options))
      end
    end
  end
end
