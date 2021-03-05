# frozen_string_literal: true

module Curator
  class Indexer::IndexingJob < ApplicationJob
    queue_as :indexing

    def perform(obj_to_index)
      obj_to_index.update_index
    end
  end
end
