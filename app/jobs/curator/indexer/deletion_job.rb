# frozen_string_literal: true

module Curator
  class Indexer::DeletionJob < ApplicationJob
    queue_as :indexing

    retry_on Curator::Exceptions::SolrUnavailable, ActiveRecord::StaleObjectError, attempts: 3, wait: 5.seconds

    before_perform { remote_service_healthcheck! }

    def perform(ark_id)
      writer = Curator.config.indexable_settings.writer_instance!
      writer.delete(ark_id)
    end

    protected

    def remote_service_healthcheck!
      Curator::Indexable.indexer_health_check!(true)
    end
  end
end
