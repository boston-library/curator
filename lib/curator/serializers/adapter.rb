# frozen_string_literal: true

module Curator
  module Serializers
    class Adapter
      attr_reader :record, :serializer_options
      def initialize(record, serializer_options = {})
        @record = record_hash
        @serializer_options = serializer_options
      end

      def serializable_hash
        raise 'Not Implmented'
      end

      def render()
        raise 'Not Implmented'
      end

      # def as_json
      #   serializable_hash
      # end
      #
      # def to_json
      #   Oj.dump(serializable_hash)
      # end
    end
  end
end
