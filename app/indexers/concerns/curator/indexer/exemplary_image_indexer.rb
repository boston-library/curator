# frozen_string_literal: true

module Curator
  class Indexer < Traject::Indexer
    module ExemplaryImageIndexer
      extend ActiveSupport::Concern
      included do
        configure do
          each_record do |record, context|
            exemplary = record.exemplary_file_set

            next if exemplary.blank?

            context.output_hash['exemplary_image_ssi'] = exemplary.ark_id
            key_base = exemplary.image_thumbnail_300&.key&.gsub(/\/[^\/]*\z/, '')
            context.output_hash['exemplary_image_key_base_ss'] = key_base

            context.output_hash['exemplary_image_iiif_bsi'] = false unless exemplary.file_set_type == 'Curator::Filestreams::Image'

            next if record.is_a?(Curator::DigitalObject)

            context.output_hash['exemplary_image_digobj_ss'] = exemplary.file_set_of.ark_id
          end
        end
      end
    end
  end
end
