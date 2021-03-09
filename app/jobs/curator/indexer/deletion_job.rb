# frozen_string_literal: true

module Curator
  class Indexer::DeletionJob < ApplicationJob
    queue_as :indexing

    def perform(ark_id)
      writer = Curator.config.indexable_settings.writer_instance!
      writer.delete(ark_id)
    end
  end
end
