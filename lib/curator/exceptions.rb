# frozen_string_literal: true

module Curator
  module Exceptions
    class CuratorError < StandardError; end
    class SerializableError < CuratorError
      # This class can raise exceptions as well as generate a serialized response object
      attr_reader :title, :detail, :status, :source

      def initialize(title: 'Something went wrong', detail: 'We encountered unexpected error', status: 500, source: {})
        @title, @detail = title, detail
        @status = Rack::Utils.status_code(code)
        @source = source.deep_stringify_keys
      end

      def to_h
        {
          status: status,
          title: title,
          detail: detail,
          source: source
        }
      end

      def serializable_hash
        to_h
      end

      def to_s
        to_h.to_s
      end
    end
  end
end
