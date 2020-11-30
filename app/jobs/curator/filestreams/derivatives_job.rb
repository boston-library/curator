# frozen_string_literal: true

module Curator
  class Filestreams::DerivativesJob < ApplicationJob
    queue_as :filestream_derivatives

    def perform(file_set_class, file_set_id)
      file_set = file_set_class.constantize.find(file_set_id)

      payload = file_set.derivatives_payload

      Curator::Filestreams::DerivativesService.call(payload: payload)
    end
  end
end
