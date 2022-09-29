# frozen_string_literal: true

module Curator
  class IIIFManifestInvalidateJob < ApplicationJob
    queue_as :default

    retry_on Curator::Exceptions::IIIFManifestEndpointUnavailable, wait: 5.seconds, attempts: 5
    retry_on Curator::Exceptions::RemoteServiceError, wait: 5.seconds, attempts: 2
    retry_on Curator::Exceptions::CuratorError, attempts: 1, wait: 5.seconds

    # @param Curator::DigitalObject#ark_id [String]
    def perform(ark_id)
      service_result = Curator::IIIFManifestInvalidateService.call(ark_id)

      logger.info "IIIF Manifest invalidate enpoint returned #{service_result}"
    end

    protected

    def remote_service_healthcheck!
      raise Curator::Exceptions::IIIFManifestEndpointUnavailable if !iiif_manifest_endpoint_ready?
    end

    private

    def iiif_manifest_endpoint_ready?
      Curator::IIIFManifestInvalidateService.ready?
    end
  end
end
