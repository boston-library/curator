# frozen_string_literal: true

# based on https://github.com/sciencehistory/kithe/blob/ae4f1780451b4f15577b298f57503880cc2c4681/app/indexing/kithe/indexable.rb
module Curator
  module Indexable
    extend ActiveSupport::Concern

    # Set some indexing parameters for the block yielded. For instance, to batch updates:
    #
    #     Curator::Indexable.index_with(batching: true)
    #        lots_of_records.each(&:update_index)
    #     end
    #
    # And they will use a batching Traject writer for much more efficiency.
    #
    # Also pass in custom writer or mapper to #update_index
    #
    # If using ActiveRecord transactions, `.transaction do` should be INSIDE `index_with`,
    # not outside.
    def self.index_with(batching: false, disable_callbacks: false, writer: nil, on_finish: nil)
      settings = ThreadSettings.push(
        batching: batching,
        disable_callbacks: disable_callbacks,
        writer: writer,
        on_finish: on_finish
      )
      yield settings
    ensure
      settings&.pop
    end

    def self.indexer_health_check!(for_destroy = false)
      raise Curator::Exceptions::SolrUnavailable if !solr_service_ready?

      return if for_destroy

      raise Curator::Exceptions::AuthorityApiUnavailable if !authority_service_ready?
    end

    # Are automatic after_commit callbacks currently enabled? Will check a number
    # of things to see, as we have a number of places these can be turned on/off.
    # * Globally in `Curator.config.indexable_settings.disable_callback`
    # * On class or instance using class_attribute `curator_indexable_auto_callbacks`
    # * If no curator_indexable_mapper is configured on record, then no callbacks.
    # * Using thread-current settings usually set by .index_with
    def self.auto_callbacks?(model)
      !Curator.config.indexable_settings.disable_callbacks &&
          model.curator_indexable_auto_callbacks &&
          model.curator_indexable_mapper &&
          !ThreadSettings.current.disabled_callbacks?
    end

    class << self
      protected

      def authority_service_ready?
        Curator::ControlledTerms::AuthorityService.ready?
      end

      def solr_service_ready?
        Curator::SolrUtil.ready?
      end
    end

    included do
      # in including model class, set to an _instance_ of a Curator::Indexer or Traject::Indexer subclass.
      # as in: self.curator_indexable_mapper = MyWorkIndexer.new
      #
      # Re-using the same instance performs better because of how traject is set up,
      # although may do weird things with dev-mode class reloading
      class_attribute :curator_indexable_mapper

      # whether to invoke after_commit callback. true = auto indexing
      class_attribute :curator_indexable_auto_callbacks, default: true

      after_save_commit :queue_indexing_job, if: -> { Curator::Indexable.auto_callbacks?(self) }
      after_destroy_commit :queue_deletion_job, if: -> { Curator::Indexable.auto_callbacks?(self) }
    end

    # Update the Solr index for this object -- may add or remove from index depending on state.
    # By default will use:
    #  - curator_indexable_mapper
    #  - a per-update writer, or thread/block-specific writer configured with `self.index_with`
    def update_index(mapper: curator_indexable_mapper, writer: nil)
      RecordIndexUpdater.new(self, mapper: mapper, writer: writer).update_index
    end

    def queue_indexing_job
      if %i(inline test).member?(Rails.application.config.active_job[:queue_adapter])
        Curator::Indexer::IndexingJob.perform_later(self.class.name, id)
      else
        Curator::Indexer::IndexingJob.set(wait: 2.seconds).perform_later(self.class.name, id)
      end
    end

    def queue_deletion_job
      if %i(inline test).member?(Rails.application.config.active_job[:queue_adapter])
        Curator::Indexer::DeletionJob.perform_later(ark_id)
      else
        Curator::Indexer::DeletionJob.set(wait: 2.seconds).perform_later(ark_id)
      end
    end
  end
end
