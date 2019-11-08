# frozen_string_literal: true

module Curator
  class InstitutionIndexer < Curator::Indexer
    # TODO: add indexing for:
    #         publishing_state_ssi destination_site_ssim
    #         subject_geo_country_ssim subject_geo_state_ssim subject_geo_county_ssim
    #         subject_geo_city_ssim subject_geo_citysection_ssim
    #         subject_geographic_tsim subject_geographic_ssim
    #         subject_coordinates_geospatial subject_point_geospatial
    #         subject_geojson_facet_ssim subject_hiergeo_geojson_ssm
    configure do
      to_field %w(title_info_primary_tsi physical_location_ssim), obj_extract('name')
      to_field 'title_info_primary_ssort' do |record, accumulator, _context|
        accumulator << Curator::Parsers::InputParser.get_proper_title(record.send(:name)).last
      end
      to_field 'abstract_tsi', obj_extract('abstract')
      to_field 'institution_url_ss', obj_extract('url')
      to_field %w(genre_basic_ssim genre_basic_tsim), obj_extract('class', 'name', 'demodulize')
    end

    # NOTE: fields below were set in Bplmodels::Institution#to_solr, but no longer needed(?):
    #         ingest_origin_ssim ingest_path_ssim exemplary_image_ssi physical_location_tsim
  end
end
