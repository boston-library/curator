# frozen_string_literal: true

module Curator::Exceptions
  class IndexerError < CuratorError
    def initialize(message = 'An error occcured indexing a record!')
      super(message)
    end
  end

  class IndexerBadRequestError < IndexerError
    attr_reader :response

    def initialize(message, response = nil)
      super(message)
      @response = response
    end
  end

  class GeographicIndexerError < IndexerError
    attr_reader :geo_auth_url

    def initialize(message = 'Failed to retreive geograhic index data from authority api!', geo_auth_url)
      super(message)
      @geo_auth_url = geo_auth_url
    end
  end
end
