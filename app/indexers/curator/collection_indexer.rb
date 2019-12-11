# frozen_string_literal: true

module Curator
  class CollectionIndexer < Curator::Indexer
    include Curator::Indexer::WorkflowIndexer
    include Curator::Indexer::AdministrativeIndexer

    # NOTE: fields below were previously set in Bplmodels::Collection#to_solr, but no longer needed(?):
    #   label_ssim

    # NOTE: fields below were previously set in Bplmodels::Collection#to_solr, but have been updated:
    #   institution_pid_ssi->institution_ark_id_ssi institution_name_ssim->institution_name_ssi
    #   institution_name_tsim->institution_name_ti genre_basic_tsim->genre_basic_tim
    #   physical_location_tsim->physical_location_tim

    # TODO: add indexing for:
    #         genre_basic_ssim genre_basic_tim edit_access_group_ssim
    configure do
      to_field 'title_info_primary_tsi', obj_extract('name')
      to_field 'title_info_primary_ssort' do |record, accumulator|
        accumulator << Curator::Parsers::InputParser.get_proper_title(record.name).last
      end
      to_field 'abstract_tsi', obj_extract('abstract')
      to_field %w(physical_location_ssim physical_location_tim institution_name_ssi institution_name_ti),
               obj_extract('institution', 'name')
      to_field 'institution_ark_id_ssi', obj_extract('institution', 'ark_id')

      to_field 'exemplary_image_ssi', obj_extract('exemplary_file_set', 'ark_id')
      to_field 'exemplary_image_iiif_bsi' do |record, accumulator|
        exemplary_file_set_type = record.exemplary_file_set&.file_set_type
        accumulator << false unless exemplary_file_set_type == 'Curator::Filestreams::Image'
      end
    end
  end
end
