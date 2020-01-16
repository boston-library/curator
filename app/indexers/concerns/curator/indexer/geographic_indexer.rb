# frozen_string_literal: true

module Curator
  class Indexer < Traject::Indexer
    module GeographicIndexer
      extend ActiveSupport::Concern
      included do
        configure do
          each_record do |record, context|
            next unless record.descriptive&.subject_geos

            geo_fields = %w(subject_geographic_tim subject_geographic_ssim subject_geo_city_ssim
                            subject_coordinates_geospatial subject_point_geospatial subject_bbox_geospatial
                            subject_geojson_facet_ssim)
            geo_fields.each do |geo_field|
              context.output_hash[geo_field] = []
            end
            record.descriptive.subject_geos.each do |subject_geo|
              geo_label = subject_geo.label
              context.output_hash['subject_geographic_tim'] << geo_label
              context.output_hash['subject_geographic_ssim'] << geo_label
              if subject_geo.area_type == 'city' || subject_geo.area_type == 'city_section'
                context.output_hash['subject_geo_city_ssim'] << geo_label
              end

              coords = subject_geo.coordinates
              context.output_hash['subject_point_geospatial'] << coords
              context.output_hash['subject_coordinates_geospatial'] << coords

              bbox = subject_geo.bounding_box
              bbox_to_env = Curator::Parsers::GeoParser.bbox_formatter(bbox, 'wkt_envelope') if bbox
              context.output_hash['subject_bbox_geospatial'] << bbox_to_env
              context.output_hash['subject_coordinates_geospatial'] << bbox_to_env

              next unless coords || bbox

              geojson_hash = { type: 'Feature', geometry: {} }
              if bbox
                unless bbox == '-180.0 -90.0 180.0 90.0' # don't want 'whole world' bboxes
                  geojson_hash[:bbox] = bbox.split(' ').map(&:to_f)
                  geojson_hash[:geometry][:type] = 'Polygon'
                  geojson_hash[:geometry][:coordinates] = [
                      Curator::Parsers::GeoParser.bbox_formatter(bbox, 'wkt_array')
                  ]
                end
              elsif coords
                geojson_hash[:geometry][:type] = 'Point'
                geojson_hash[:geometry][:coordinates] = coords.split(',').reverse.map(&:to_f)
              end
              geojson_hash[:properties] = { placename: geo_label } if geo_label
              context.output_hash['subject_geojson_facet_ssim'] << geojson_hash.to_json
            end
          end
        end
      end
    end
  end
end
