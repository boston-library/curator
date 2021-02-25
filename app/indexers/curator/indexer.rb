# frozen_string_literal: true

# based on https://github.com/sciencehistory/kithe/blob/ae4f1780451b4f15577b298f57503880cc2c4681/app/indexing/kithe/indexer.rb
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
      to_field 'system_create_dtsi', obj_extract('created_at')
      to_field 'system_modified_dtsi', obj_extract('updated_at')
      to_field Curator.config.indexable_settings.model_name_solr_field, obj_extract('class', 'name')
      to_field 'curator_model_suffix_ssi', obj_extract('class', 'name', 'demodulize')
    end
  end
end
