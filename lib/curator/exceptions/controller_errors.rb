# frozen_string_literal: true

module Curator::Exceptions
  # Raiseable Exceptions

  class UnknownFormat < CuratorError; end
  class UnknownSerializer < CuratorError; end
  class UnknownResourceType < CuratorError; end

  # Server Response Exceptions
  # 40x Response Codes
  class BadRequest < SerializableError
    def initialize(message = 'Request query or payload is invalid', pointer = 'request/params')
      super(
        title: 'Bad Request',
        status: :bad_request,
        detail: message,
        source: { pointer: pointer }
      )
    end
  end

  class Unauthorized < SerializableError
    def initialize(message = 'You must be logged in to do this', pointer = 'request/headers/authorization')
      super(
        title: 'Unauthorized',
        status: :unauthorized,
        detail: message,
        source: { pointer: pointer }
      )
    end
  end


  class RouteNotFound < SerializableError
    def initialize(message = 'Unknown request URL', pointer = '/request/url')
      super(
        title: 'URL Not Found',
        status: :not_found,
        detail: message ,
        source: { pointer: pointer }
      )
    end
  end

  class RecordNotFound < SerializableError
    def initialize(message = 'Object not found', pointer = '/request/url/:identifier')
      super(
        title: 'Record Not Found',
        status: :not_found,
        detail: message,
        source: { pointer: pointer }
      )
    end
  end

  class NotAcceptable < SerializableError
    def initialize(message = 'Method not allowed in requested format', pointer = '/headers/:content_type')
      super(
        title: 'Not Acceptable',
        status: :not_acceptable,
        detail: message,
        source: { pointer: pointer }
      )
    end
  end

  # 50x response codes
  class ServerError < SerializableError
    def initialize(message = 'Unknown internal server error', pointer = 'unknown')
      super(
        title: 'Internal Server Error',
        status: :internal_server_error,
        detail: message,
        source: { pointer: pointer }
      )
    end
  end
end
