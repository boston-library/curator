# frozen_string_literal: true

module Curator
  class Filestreams::IIIFManifestInvalidateService < Services::Base
    include Curator::Services::RemoteService

    self.base_url = Curator.config.iiif_manifest_url
    self.default_path_prefix = '/search'
    self.timeout_options = Curator.config.default_remote_service_timeout_opts

    attr_reader :ark_id

    def initialize(ark_id)
      @ark_id = ark_id
    end

    def call
    end

    protected

    def call_invalidate_iiif_manifest(client)
    end
  end
end
