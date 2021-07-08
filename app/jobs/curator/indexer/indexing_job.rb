# frozen_string_literal: true

module Curator
  class Indexer::IndexingJob < ApplicationJob
    queue_as :indexing

    retry_on Curator::Exceptions::SolrUnavailable, Curator::Exceptions::AuthorityApiUnavailable, attempts: 3

    def perform(obj_to_index)
      obj_to_index.indexer_health_check
      obj_to_index.update_index
    end
  end
end
