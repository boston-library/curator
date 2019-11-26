# frozen_string_literal: true

module Curator
  class CollectionIndexer < Curator::Indexer
    # NOTE: fields below were previously set in Bplmodels::Collection#to_solr, but no longer needed(?):
    #   label_ssim

    # NOTE: fields below were previously set in Bplmodels::Collection#to_solr, but have been updated:
    #   institution_pid_ssi->institution_ark_id_ssi institution_name_ssim->institution_name_ssi
    #   institution_name_tsim->institution_name_tsi

    # TODO: add indexing for:
    #         publishing_state_ssi destination_site_ssim harvesting_status_bsi
    #         genre_basic_ssim genre_basic_tsim
    configure do
      to_field 'title_info_primary_tsi', obj_extract('name')
      to_field 'title_info_primary_ssort' do |record, accumulator, _context|
        accumulator << Curator::Parsers::InputParser.get_proper_title(record.send(:name)).last
      end
      to_field 'abstract_tsi', obj_extract('abstract')
      to_field %w(physical_location_ssim physical_location_tsim institution_name_ssi institution_name_tsi),
               obj_extract('institution', 'name')
      to_field 'institution_ark_id_ssi', obj_extract('institution', 'ark_id')

      to_field 'exemplary_image_ssi', obj_extract('exemplary_file_set', 'ark_id')
      to_field 'exemplary_image_iiif_bsi' do |record, accumulator, _context|
        exemplary_file_set_type = record.exemplary_file_set&.file_set_type
        accumulator << false unless exemplary_file_set_type == 'Curator::Filestreams::Image'
      end
    end
  end
end
