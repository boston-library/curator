# frozen_string_literal: true

module Curator
  class DigitalObjectIndexer < Curator::Indexer
    # NOTE: fields below were previously set in Bplmodels::ObjectBase#to_solr, but no longer needed(?):
    #   internet_media_type_ssim title_info_uniform_ssim classification_tsim label_ssim
    #
    # NOTE: fields below were previously set in Bplmodels::ObjectBase#to_solr, but have been updated:
    #   institution_pid_si->institution_ark_id_ssi institution_name_ssim->institution_name_ssi
    #   institution_name_tsim->institution_name_tsi collection_pid_ssm->collection_ark_id_ssim
    #   admin_set_name_ssim->admin_set_name_ssi admin_set_name_tsim admin_set_pid_ssm->admin_set_ark_id_ssi
    #   name_personal_tsim->name_tsim name_personal_role_tsim->name_role_tsim
    #   name_corporate_tsim->name_tsim name_corporate_role_tsim->name_role_tsim
    #   name_generic_tsim->name_tsim name_generic_role_tsim->name_role_tsim
    #   subject_name_personal_tsim->subject_name_tsim subject_name_corporate_tsim->subject_name_tsim
    #   subject_name_conference_tsim->subject_name_tsim
    #   subject_temporal_start_tsim->subject_date_start_tsim subject_temporal_start_dtsim->subject_date_start_dtsim
    #   subject_temporal_end_tsim->subject_date_end_tsim subject_temporal_end_dtsim->subject_date_end_dtsim
    #   subject_scale_tsim->scale_tsim subject_projection_tsim->projection_tsi
    #   edition_tsim->edition_name_tsim issuance_tsim->issuance_tsi
    #   rights_ssm->rights_ss restrictions_on_access_ssm->restrictions_on_access_ss

    # TODO: add indexing for:
    #         publishing_state_ssi processing_state_ssi destination_site_ssim harvesting_status_bsi flagged_content_ssi
    #         ocr_tiv has_searchable_text_bsi filenames_ssim is_issue_of_ssim georeferenced_bsi
    #
    #         DESCRIPTIVE:
    #         title_info_primary_tsi title_info_primary_ssort title_info_partnum_tsi title_info_partname_tsi
    #         title_info_primary_trans_tsim title_info_translated_tsim
    #         title_info_alternative_tsim title_info_uniform_tsim
    #         supplied_title_bs supplied_alternative_title_bs title_info_alternative_label_ssm subtitle_tsim
    #         genre_basic_tsim genre_basic_ssim genre_specific_tsim genre_specific_ssim
    #         type_of_resource_ssim resource_type_manuscript_bsi extent_tsi digital_origin_ssi
    #         physical_location_ssim physical_location_tsim sub_location_tsim shelf_locator_tsim
    #         abstract_tsim table_of_contents_tsi table_of_contents_url_ss
    #         date_start_dtsi date_start_tsim date_end_dtsi date_end_tsim date_facet_ssim
    #         date_type_ssm date_start_qualifier_ssm
    #         publisher_tsim pubplace_tsim issuance_tsi frequency_tsi
    #         edition_name_tsi edition_number_tsi volume_tsi issue_number_tsi text_direction_ssi
    #         lang_term_ssim
    #         related_item_constiuent_tsim related_item_constiuent_ssim
    #         related_item_host_tsim related_item_host_ssim
    #         related_item_series_tsim related_item_series_ssim
    #         related_item_subseries_tsim related_item_subseries_ssim
    #         related_item_subsubseries_tsim related_item_subsubseries_ssim
    #         related_item_isreferencedby_ssm
    #         identifier_local_other_tsim identifier_local_other_invalid_tsim
    #         identifier_local_call_tsim identifier_local_call_invalid_tsim
    #         identifier_local_barcode_tsim identifier_local_barcode_invalid_tsim
    #         identifier_local_accession_tsim identifier_isbn_tsim identifier_lccn_tsim
    #         identifier_ia_id_ssi identifier_uri_ss
    #         name_tsim name_role_tsim name_facet_ssim
    #         note_tsim note_resp_tsim note_performers_tsim note_acquisition_tsim note_ownership_tsim
    #         note_citation_tsim note_reference_tsim note_venue_tsim note_physical_tsim note_date_tsim
    #         subject_facet_ssim
    #         subject_topic_tsim
    #         subject_date_start_tsim subject_date_start_dtsim subject_date_end_tsim subject_date_end_dtsim
    #         subject_temporal_tsim subject_temporal_facet_ssim
    #         subject_title_tsim
    #         subject_geo_country_ssim subject_geo_province_ssim subject_geo_region_ssim subject_geo_territory_ssim
    #         subject_geo_state_ssim subject_geo_county_ssim subject_geo_city_ssim subject_geo_citysection_ssim
    #         subject_geo_island_ssim subject_geo_area_ssim
    #         subject_geographic_tsim subject_geographic_ssim
    #         subject_coordinates_geospatial subject_point_geospatial subject_bbox_geospatial
    #         subject_geojson_facet_ssim subject_hiergeo_geojson_ssm subject_geo_nonhier_ssim
    #         scale_tsim projection_tsi
    #         rights_ss license_ssm reuse_allowed_ssi restrictions_on_access_ss
    configure do
      to_field 'admin_set_name_ssi', obj_extract('admin_set', 'name')
      to_field 'admin_set_ark_id_ssi', obj_extract('admin_set', 'ark_id')
      to_field %w(institution_name_ssi institution_name_tsi), obj_extract('institution', 'name')
      to_field %w(collection_name_ssim collection_name_tsim) do |record, accumulator|
        record.is_member_of_collection.each { |col| accumulator << col.name }
      end
      to_field 'collection_ark_id_ssim' do |record, accumulator|
        record.is_member_of_collection.each { |col| accumulator << col.ark_id }
      end
      to_field 'institution_ark_id_ssi', obj_extract('institution', 'ark_id')
      to_field 'exemplary_image_ssi', obj_extract('exemplary_file_set', 'ark_id')
    end
  end
end
