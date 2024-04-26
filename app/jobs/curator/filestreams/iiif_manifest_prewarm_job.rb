# frozen_string_literal: true

module Curator
  class Filestreams::IIIFManifestPrewarmJob < ApplicationJob
    queue_as :default

    retry_on Curator::Exceptions::IIIFServerUnavailable, wait: 5.seconds, attempts: 5
    retry_on Curator::Exceptions::RemoteServiceError, wait: 5.seconds, attempts: 2
    retry_on Curator::Exceptions::CuratorError, attempts: 1, wait: 5.seconds

    def perform(ark_id)
      service_result = Curator::Filestreams::IIIFManifestPrewarmService.call(ark_id)

      logger.info "IIIF server responded with #{service_result}"
    end
  end
end