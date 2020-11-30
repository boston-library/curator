# frozen_string_literal: true

module Curator
  class Filestreams::DerivativesService < Services::Base
    # TODO: Set this up to be a remote service once the avi_processor is refactored
    # include Curator::Services::RemoteService

    # self.base_url = ENV['AVI_PROCESSOR_URL'].to_s
    # self.default_path_prefix = 'avi processor path prefix'
    # self.default_headers = { accept: 'application/json', content_type: 'application/json' }

    attr_reader :payload

    # Payload should be formatted as such
    # { file_set_class: demdodulized class name string,
    #   file_set_ark_id: ark_id,
    #   deriavatives: [
    #  { source_url: url to blob binary, types: [list of derviavtive types]  }
    # ]
    def initialize(payload: {})
      @payload = payload
    end

    def call
      "This is a mock service that is sending this payload \n #{@payload.inspect}"
    end
  end
end
