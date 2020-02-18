# frozen_string_literal: true

module Curator
  module Exceptions
    class RouteNotFound < SerializableError
      def initialize
        super(
          title: 'URL Not Found',
          status: :not_found,
          detail: message || 'Unknown request URL'
        )
      end
    end

    class Unauthorized < SerializableError
      def initialize
        super(
          title: 'URL Not Found',
          status: :not_found,
          detail: message || 'Unknown request URL'
        )
      end
    end

    class BadRequest < SerializableError
    end

    class ServerError < SerializableError
      def initialize
        super(
          title: 'Internal Server Error',
          status: :internal_server_error,
          detail: message || 'Error'
        )
      end
    end
  end
end
