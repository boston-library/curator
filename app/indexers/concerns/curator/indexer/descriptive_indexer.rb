# frozen_string_literal: true

module Curator
  class Indexer < Traject::Indexer
    module DescriptiveIndexer
      extend ActiveSupport::Concern
      include Curator::Indexer::TitleIndexer
      include Curator::Indexer::GenreIndexer
      include Curator::Indexer::DateIndexer
      include Curator::Indexer::NameRoleIndexer
      include Curator::Indexer::RelatedItemIndexer
      include Curator::Indexer::PhysicalLocationIndexer
      include Curator::Indexer::IdentifierIndexer
      include Curator::Indexer::NoteIndexer
      include Curator::Indexer::PublicationIndexer
      include Curator::Indexer::CartographicIndexer
      include Curator::Indexer::RightsLicenseIndexer
      included do
        configure do
          to_field 'digital_origin_ssi', obj_extract('descriptive', 'digital_origin')
          to_field 'extent_tsi', obj_extract('descriptive', 'extent')
          to_field 'abstract_tsi', obj_extract('descriptive', 'abstract')
          to_field 'table_of_contents_tsi', obj_extract('descriptive', 'toc')
          to_field 'table_of_contents_url_ss', obj_extract('descriptive', 'toc_url')
          to_field 'publisher_tsi', obj_extract('descriptive', 'publisher')
          to_field 'pubplace_tsi', obj_extract('descriptive', 'place_of_publication')
          to_field 'issuance_tsi', obj_extract('descriptive', 'issuance')
          to_field 'frequency_tsi', obj_extract('descriptive', 'frequency')
          to_field 'text_direction_ssi', obj_extract('descriptive', 'text_direction')
          to_field 'resource_type_manuscript_bsi', obj_extract('descriptive', 'resource_type_manuscript')
          to_field 'type_of_resource_ssim' do |record, accumulator|
            record.descriptive.resource_types.each do |type|
              accumulator << type.label
            end if record.descriptive&.resource_types
          end
          to_field 'lang_term_ssim' do |record, accumulator|
            record.descriptive.languages.each do |lang|
              accumulator << lang.label
            end if record.descriptive&.languages
          end
        end
      end
    end
  end
end
