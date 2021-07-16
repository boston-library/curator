# frozen_string_literal: true

module Curator
  class Indexer::IndexingJob < ApplicationJob
    queue_as :indexing

    retry_on Curator::Exceptions::SolrUnavailable, Curator::Exceptions::AuthorityApiUnavailable, ActiveRecord::StaleObjectError, attempts: 3
    retry_on Curator::Exceptions::GeographicIndexerError, attempts: 1

    before_perform  { remote_service_healthcheck! }

    def perform(obj_to_index)
      obj_to_index.update_index
    end

    protected

    def remote_service_healthcheck!
      raise Curator::Exceptions::SolrUnavailable if !solr_service_ready?
      raise Curator::Exceptions::AuthorityApiUnavailable if !authority_service_ready?
    end

    private

    def authority_service_ready?
      Curator::ControlledTerms::AuthorityService.ready?
    end

    def solr_service_ready?
      Curator::SolrUtil.ready?
    end
  end
end
