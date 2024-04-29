# frozen_string_literal: true

module Curator
  class Filestreams::IIIFCacheInvalidateJob < ApplicationJob
    include Curator::Filestreams::IIIFReadyable
    queue_as :iiif

    retry_on Curator::Exceptions::IIIFServerUnavailable, wait: 5.seconds, attempts: 5
    retry_on Curator::Exceptions::RemoteServiceError, wait: 5.seconds, attempts: 2
    retry_on Curator::Exceptions::CuratorError, attempts: 1, wait: 5.seconds

    before_perform { remote_service_healthcheck! }

    # @param Curator::Filestreams::Image#ark_id [String]
    def perform(ark_id)
      service_result = Curator::Filestreams::IIIFServerCacheInvalidateService.call(ark_id)

      logger.info "IIIF server responded with #{service_result}"
    end

    private

    def iiif_server_ready?
      Curator::Filestreams::IIIFServerCacheInvalidateService.ready?
    end
  end
end
