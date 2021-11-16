# frozen_string_literal: true

module Curator::Exceptions
  class IndexerError < CuratorError
    def initialize(message = 'An error occurred indexing a record!')
      super(message)
    end
  end

  class IndexerBadRequestError < IndexerError
    attr_reader :response

    def initialize(message = 'Indexer returned 400 bad request!', response = nil)
      super(message)
      @response = response
    end
  end

  class GeographicIndexerError < IndexerError
    attr_reader :geo_auth_url

    def initialize(message = 'Failed to retrieve geographic index data from authority api!', geo_auth_url = nil)
      super(message)
      @geo_auth_url = geo_auth_url
    end
  end
end
