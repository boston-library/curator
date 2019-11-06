# frozen_string_literal: true

# based on https://github.com/sciencehistory/kithe/blob/master/app/indexing/kithe/indexer.rb
require 'traject'

module Curator
  class Indexer < Traject::Indexer
    include Curator::Indexer::ObjExtract

    # not used for writing. 0 threads.
    def self.default_settings
      @default_settings ||= super.merge(
        'processing_thread_pool' => 0,
        'writer_class_name' => 'NoWriterSet',
        'logger' => Rails.logger
      )
    end

    # index model name and id by default
    configure do
      to_field 'id', obj_extract('ark_id')
      to_field Curator.indexable_settings.model_name_solr_field, obj_extract('class', 'name')
    end
  end
end
