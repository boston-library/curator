# frozen_string_literal: true

module Curator
  class ArkDeleteJob < ApplicationJob
    queue_as :arks

    retry_on Curator::Exceptions::ArkManagerApiUnavailable, ActiveRecord::RecordNotDestroyed, attempts: 3

    before_perform do
      minter_service_available = Curator::MinterService.ready?

      raise Curator::Exceptions::ArkManagerApiUnavailable if !minter_service_available
    end

    def perform(ark_id)
      Curator::ArkDeleteService.call(ark_id)
    end
  end
end
