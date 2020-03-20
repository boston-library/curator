# frozen_string_literal: true

module Curator
  class Indexer < Traject::Indexer
    module GeographicIndexer
      extend ActiveSupport::Concern
      included do
        configure do
          each_record do |record, context|
            # handle both DigitalObject and Institution
            geo_subjects = record.try(:descriptive)&.subject_geos || Array.wrap(record.try(:location))
            next unless geo_subjects.present?

            geo_fields = %w(subject_geographic_tim subject_geographic_sim subject_geo_label_sim
                            subject_geo_citysection_sim subject_geo_city_sim subject_geo_county_sim
                            subject_geo_state_sim subject_geo_country_sim subject_geo_continent_sim 
                            subject_geo_other_ssm subject_coordinates_geospatial subject_point_geospatial 
                            subject_bbox_geospatial subject_geojson_facet_ssim subject_hiergeo_geojson_ssm)
            geo_fields.each { |geo_field| context.output_hash[geo_field] = [] }

            geo_subjects.each do |subject_geo|
              geo_label = subject_geo.label
              display_placename = geo_label
              geo_auth = subject_geo.authority&.code
              coords = subject_geo.coordinates
              context.output_hash['subject_geo_label_sim'] << geo_label if geo_auth

              if geo_auth == 'tgn' || geo_auth == 'geonames'
                auth_url = "#{ENV['AUTHORITY_API_URL']}/geomash/#{geo_auth}/#{subject_geo.id_from_auth}"
                auth_data = Curator::ControlledTerms::CannonicalLabelService.call(url: auth_url,
                                                                                  json_path: nil)
                if auth_data && auth_data[:hier_geo].present?
                  auth_data[:hier_geo] = Curator::Parsers::GeoParser.normalize_geonames_hgeo(auth_data[:hier_geo]) if geo_auth == 'geonames'
                  auth_data[:hier_geo].each do |k, v|
                    context.output_hash['subject_geographic_tim'] << v
                    v += ' (county)' if k == 'county'
                    context.output_hash['subject_geographic_sim'] << v
                    context.output_hash["subject_geo_#{k}_sim"] << v if context.output_hash["subject_geo_#{k}_sim"]
                  end
                  context.output_hash['subject_geo_other_ssm'] << auth_data[:hier_geo][:other]
                  hiergeo_geojson = { type: 'Feature',
                                      geometry: { type: 'Point',
                                                  coordinates: coords&.split(',')&.reverse&.map(&:to_f) },
                                      properties: auth_data[:hier_geo] }
                  context.output_hash['subject_hiergeo_geojson_ssm'] << hiergeo_geojson.to_json
                  display_placename = Curator::Parsers::GeoParser.display_placename(auth_data[:hier_geo])
                end
              else
                context.output_hash['subject_geographic_tim'] << geo_label
                context.output_hash['subject_geographic_sim'] << geo_label
                context.output_hash['subject_geo_other_ssm'] << geo_label
              end

              context.output_hash['subject_point_geospatial'] << coords
              context.output_hash['subject_coordinates_geospatial'] << coords

              bbox = subject_geo.bounding_box
              bbox_to_env = Curator::Parsers::GeoParser.bbox_formatter(bbox, 'wkt_envelope') if bbox
              context.output_hash['subject_bbox_geospatial'] << bbox_to_env
              context.output_hash['subject_coordinates_geospatial'] << bbox_to_env

              if coords || bbox
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
                geojson_hash[:properties] = { placename: display_placename } if display_placename
                context.output_hash['subject_geojson_facet_ssim'] << geojson_hash.to_json
              end
            end
            geo_fields.each { |geo_field| context.output_hash[geo_field].uniq! }
          end
        end
      end
    end
  end
end
