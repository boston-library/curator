# frozen_string_literal: true

module Curator
  class Indexer::IndexingJob < ApplicationJob
    queue_as :indexing

    retry_on Curator::Exceptions::SolrUnavailable, Curator::Exceptions::AuthorityApiUnavailable, ActiveRecord::StaleObjectError, attempts: 3

    before_perform do
      raise Curator::Exceptions::SolrUnavailable if !Curator::SolrUtil.ready?
      raise Curator::Exceptions::AuthorityApiUnavailable if !Curator::ControlledTerms::AuthorityService.ready?
    end

    def perform(obj_to_index)
      obj_to_index.update_index
    end
  end
end
