# frozen_string_literal: true

module Curator
  class Indexer::IndexingJob < ApplicationJob
    queue_as :indexing

    retry_on Curator::Exceptions::SolrUnavailable, Curator::Exceptions::AuthorityApiUnavailable,
             ActiveRecord::StaleObjectError, Curator::Exceptions::AllmapsAnnotationsUnavailable, attempts: 3, wait: 5.seconds
    retry_on Curator::Exceptions::GeographicIndexerError, wait: 5.seconds, attempts: 1 do |_job, error|
      logger.error "#{error.message}; URL PATH: #{error&.geo_auth_url}"
    end

    before_perform { remote_service_healthcheck! }

    def perform(obj_class, obj_id)
      ActiveRecord::Base.connection_pool.with_connection do
        indexable_object = Object.const_get(obj_class).for_reindex_all.find(obj_id)
        indexable_object.update_index
      end
    ensure
      ActiveRecord::Base.connection_handler.clear_active_connections!
    end

    protected

    def remote_service_healthcheck!
      Curator::Indexable.indexer_health_check!
    end
  end
end
