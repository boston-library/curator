# frozen_string_literal: true

module Curator
  class Indexer < Traject::Indexer
    module ExemplaryImageIndexer
      extend ActiveSupport::Concern
      included do
        configure do
          each_record do |record, context|
            exemplary = if record.is_a?(Curator::Institution)
                          record if record.image_thumbnail_300.attached?
                        else
                          record.exemplary_file_set
                        end
            next if exemplary.blank?

            context.output_hash['exemplary_image_ssi'] = exemplary.ark_id
            key_base = exemplary&.image_thumbnail_300&.key&.gsub(/\/[^\/]*\z/, '')
            context.output_hash['exemplary_image_key_base_ss'] = key_base

            next unless exemplary.respond_to?(:file_set_type)

            context.output_hash['exemplary_image_iiif_bsi'] = false unless exemplary.file_set_type == 'Curator::Filestreams::Image'
          end
        end
      end
    end
  end
end
