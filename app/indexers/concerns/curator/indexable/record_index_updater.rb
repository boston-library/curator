# frozen_string_literal: true

# based on https://github.com/sciencehistory/kithe/blob/ae4f1780451b4f15577b298f57503880cc2c4681/app/indexing/kithe/indexable/record_index_updater.rb
module Curator
  module Indexable
    # The class actually responsible for updating a record to Solr.
    # Normally called from #update_index in a Curator::Indexable model.
    #
    #     Curator::Indexable::RecordIndexUpdater.new(model).update_index
    #
    # #update_index can add _or_ remove the model from Solr index, depending on model
    # state.
    #
    # The RecordIndexUpdater will determine the correct Traject::Writer to send output to, from local
    # initialize argument, current thread settings (usually set by Curator::Indexable.index_with),
    # or global settings.
    class RecordIndexUpdater
      # record to be sync'd to Solr or other index
      attr_reader :record

      # @param record [ActiveRecord::Base] Curator::Model record to be sync'd to index
      # @param mapper [Traject::Indexer]
      # @param writer [Traject::Writer]
      def initialize(record, mapper: nil, writer: nil)
        @record = record
        @writer = writer
        @mapper = mapper
      end

      # Sync #record to the (Solr) index. Depending on record state, we may:
      #
      # * Add object to index. Run it through the current #mapper, then send it to the
      #   current #writer with `writer.put`
      # * Remove object from index. Call `#delete(ark_id)` on the current #writer.
      def update_index
        if should_be_in_index?
          mapper.process_with([record]) do |context|
            writer.put(context)
          end
        else
          writer.delete(record.ark_id)
        end
      end

      # The Traject::Indexer we'll use to map the #record into an index representation,
      # by calling #process_with on the indexer.
      #
      # If a mapper was passed in #initialize, that'll be used. Otherwise the one set
      # on the record's class_attribute `curator_indexable_mapper` will be used.
      def mapper
        @mapper ||= begin
          if record.curator_indexable_mapper.nil?
            raise TypeError.new("Can't call update_index without `curator_indexable_mapper` given for #{record.inspect}")
          end
          record.curator_indexable_mapper
        end
      end

      # The Traject::Writer we'll send the indexed representation to after mapping it.
      # Could be an explicit writer passed into #initialize, or a current thread-settings
      # writer, or a new writer created from global settings.
      def writer
        @writer ||= ThreadSettings.current.writer || Curator.indexable_settings.writer_instance!
      end

      # Is this record supposed to be represented in the solr index?
      def should_be_in_index?
        # TODO, add a record should_index? method like searchkick
        # https://github.com/ankane/searchkick/blob/5d921bc3da69d6105cbc682ea3df6dce389b47dc/lib/searchkick/record_indexer.rb#L44
        !record.destroyed? && record.persisted?
      end
    end
  end
end
