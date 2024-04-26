# frozen_string_literal: true

module Curator
  class Filestreams::IIIFManifestPrewarmService < Services::Base
    include Curator::Services::RemoteService

    self.base_url = Curator.config.iiif_server_url
    self.default_headers = { content_type: 'application/json' }
    self.timeout_options = Curator.config.default_remote_service_timeout_opts

    attr_reader :ark_id

    def initialize(ark_id)
      @ark_id = ark_id
    end

    def call
    end
  end
end