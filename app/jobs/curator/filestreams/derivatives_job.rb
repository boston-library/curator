# frozen_string_literal: true

module Curator
  class Filestreams::DerivativesJob < ApplicationJob
    queue_as :filestream_derivatives

    retry_on Curator::Exceptions::AviProcessorApiUnavailable, ActiveRecord::StaleObjectError, wait: 5.seconds, attempts: 5
    retry_on Curator::Exceptions::RemoteServiceError, wait: 5.seconds, attempts: 2
    retry_on Curator::Exceptions::CuratorError, attempts: 1, wait: 5.seconds

    before_perform { remote_service_healthcheck! }

    def perform(file_set_class_name, file_set_id)
      file_set = Object.const_get(file_set_class_name).find(file_set_id)
      avi_file_class = file_set.avi_file_class
      avi_payload = file_set.avi_payload

      raise Curator::Exceptions::CuratorError, "No source file for derivatives file not attached! for #{file_set.class.name}-#{file_set.ark_id}" if avi_payload.blank?

      service = Curator::Filestreams::DerivativesService.call(avi_file_class, avi_payload: avi_payload)

      logger.info "AVI Processor returned response: #{service}"
    end

    protected

    def remote_service_healthcheck!
      raise Curator::Exceptions::AviProcessorApiUnavailable if !avi_processor_service_ready?
    end

    private

    def avi_processor_service_ready?
      Curator::Filestreams::DerivativesService.ready?
    end
  end
end
