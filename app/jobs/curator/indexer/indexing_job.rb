# frozen_string_literal: true

module Curator
  class Indexer::IndexingJob < ApplicationJob
    queue_as :indexing

    retry_on Curator::Exceptions::SolrUnavailable, Curator::Exceptions::AuthorityApiUnavailable, ActiveRecord::StaleObjectError, attempts: 3, wait: 5.seconds
    retry_on Curator::Exceptions::GeographicIndexerError, wait: 5.seconds, attempts: 1 do |_job, error|
      logger.error "#{error.message}; URL PATH: #{error&.geo_auth_url}"
    end

    before_perform { remote_service_healthcheck! }

    def perform(obj_class, obj_id)
      indexable_object = Object.const_get(obj_class).for_reindex_all.find(obj_id)
      indexable_object.update_index
    end

    protected

    def remote_service_healthcheck!
      Curator::Indexable.indexer_health_check!
    end
  end
end
