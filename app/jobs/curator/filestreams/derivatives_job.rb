# frozen_string_literal: true

module Curator
  class Filestreams::DerivativesJob < ApplicationJob
    queue_as :filestream_derivatives

    def perform(file_set)
      payload = file_set.derivatives_payload

      Curator::Filestreams::DerivativesService.call(payload: payload)
    end
  end
end
