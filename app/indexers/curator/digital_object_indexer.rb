# frozen_string_literal: true

module Curator
  class DigitalObjectIndexer < Curator::Indexer
    include Curator::Indexer::DescriptiveIndexer
    include Curator::Indexer::WorkflowIndexer
    include Curator::Indexer::AdministrativeIndexer

    # NOTE: fields below were previously set in Bplmodels::ObjectBase#to_solr, but no longer needed(?):
    #   internet_media_type_ssim classification_tsim label_ssim date_facet_ssim supplied_alternative_title_bs
    #   supplied_title_bs
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
    #   publisher_tsim->publisher_tsi pubplace_tsim->pubplace_tsi abstract_tsim->abstract_tsi
    #   genre_basic_tsim->genre_basic_tim genre_specific_tsim->genre_specific_tim
    #   related_item_host_tsim->related_item_host_tim related_item_series_tsim->related_item_series_tim
    #   related_item_subseries_tsim->related_item_subseries_tim related_item_subsubseries_tsim->related_item_subsubseries_tim
    #   institution_name_tsi->institution_name_ti collection_name_tsim->collection_name_tim
    #   physical_location_tsim->physical_location_tim sub_location_tsim->sub_location_tsi shelf_locator_tsim->shelf_locator_tsi
    #   date_facet_yearly_ssim->date_facet_yearly_itim subtitle_tsim->title_info_other_subtitle_tsim
    #
    # NOTE: fields below are new:
    #   title_info_primary_subtitle_tsi date_edtf_ssm

    # TODO: add indexing for:
    #         ocr_tiv has_searchable_text_bsi filenames_ssim is_issue_of_ssim georeferenced_bsi edit_access_group_ssim
    #
    #         DESCRIPTIVE:

    #
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
    configure do
      to_field 'admin_set_name_ssi', obj_extract('admin_set', 'name')
      to_field 'admin_set_ark_id_ssi', obj_extract('admin_set', 'ark_id')
      to_field %w(institution_name_ssi institution_name_ti), obj_extract('institution', 'name')
      to_field 'institution_ark_id_ssi', obj_extract('institution', 'ark_id')
      to_field %w(collection_name_ssim collection_name_tim) do |record, accumulator|
        record.is_member_of_collection.each { |col| accumulator << col.name }
      end
      to_field 'collection_ark_id_ssim' do |record, accumulator|
        record.is_member_of_collection.each { |col| accumulator << col.ark_id }
      end
      to_field 'exemplary_image_ssi', obj_extract('exemplary_file_set', 'ark_id')
    end
  end
end
