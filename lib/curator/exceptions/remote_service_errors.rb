# frozen_string_literal: true

module Curator::Exceptions
  class SolrUnavailable < CuratorError
    def message
      'Solr is not available'
    end
  end

  class AuthorityApiUnavailable < CuratorError
    def message
      'Authority API is not available'
    end
  end

  # NOTE: do not inherit sub classes from this
  class RemoteServiceError < CuratorError
    attr_reader :json_response, :code

    def initialize(msg = 'Error Occurred With RemoteService Client', json_response = {}, code = 500)
      @json_response = JSON.pretty_generate(json_response)
      @code = code
      super(msg)
    end
  end
end
