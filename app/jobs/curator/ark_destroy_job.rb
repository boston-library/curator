# frozen_string_literal: true

module Curator
  class ArkDestroyJob < ApplicationJob
    queue_as :arks

    retry_on Curator::Exceptions::ArkManagerApiUnavailable, ActiveRecord::RecordNotDestroyed, attempts: 3

    before_perform { remote_service_healthcheck! }

    def perform(ark_id)
      Curator::ArkDestroyService.call(ark_id)
    end

    protected

    def remote_service_healthcheck!
      raise Curator::Exceptions::ArkManagerApiUnavailable if !ark_destroy_service_ready?
    end

    private

    def ark_destroy_service_ready?
      Curator::ArkDestroyService.ready?
    end
  end
end
