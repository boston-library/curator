# frozen_string_literal: true

module Curator
  class Filestreams::DerivativesJob < ApplicationJob
    queue_as :filestream_derivatives

    def perform(file_set)
      payload = file_set.avi_params

      raise "primary derivatives file not attached! for #{file_set.class.name}-#{file_set.ark_id}" if payload.blank?

      Curator::Filestreams::DerivativesService.call(payload: payload)
    end
  end
end
