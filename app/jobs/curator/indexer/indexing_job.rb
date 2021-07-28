# frozen_string_literal: true

module Curator
  class Indexer::IndexingJob < ApplicationJob
    queue_as :indexing

    retry_on Curator::Exceptions::SolrUnavailable, Curator::Exceptions::AuthorityApiUnavailable, ActiveRecord::StaleObjectError, attempts: 3
    retry_on Curator::Exceptions::GeographicIndexerError, attempts: 1 do |_job, error|
      logger.error "#{error.message}; URL PATH: #{error&.geo_auth_url}"
    end

    before_perform { remote_service_healthcheck! }

    def perform(obj_to_index)
      obj_to_index.update_index
    end

    protected

    def remote_service_healthcheck!
      Curator::Indexable.indexer_health_check!
    end
  end
end
