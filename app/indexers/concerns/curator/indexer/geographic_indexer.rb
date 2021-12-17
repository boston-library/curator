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
            next if geo_subjects.blank?

            geo_fields = %w(subject_geographic_tim subject_geographic_sim subject_geo_label_sim
                            subject_geo_city_section_sim subject_geo_city_sim subject_geo_county_sim
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
                auth_url = "#{geo_auth}/#{subject_geo.id_from_auth}"
                auth_data = Curator::ControlledTerms::AuthorityService.call(path: auth_url, path_prefix: '/geomash')

                raise Curator::Exceptions::GeographicIndexerError.new('No data received from authority service', auth_url) if auth_data.blank?

                if auth_data[:hier_geo].present?
                  if auth_data[:non_hier_geo].present?
                    other_geo_value = auth_data[:non_hier_geo][:value]
                    other_geo_value << " (#{subject_geo.area_type})" if subject_geo.area_type.present?
                    auth_data[:hier_geo][:other] = other_geo_value
                  end
                  auth_data[:hier_geo] = if geo_auth == 'geonames'
                                           Curator::Parsers::GeoParser.normalize_geonames_hgeo(auth_data[:hier_geo])
                                         else
                                           Curator::Parsers::GeoParser.normalize_tgn_hgeo(auth_data[:hier_geo])
                                         end
                  auth_data[:hier_geo].each do |k, v|
                    context.output_hash['subject_geographic_tim'] << v
                    v += ' (county)' if k == 'county'
                    context.output_hash['subject_geographic_sim'] << v
                    context.output_hash["subject_geo_#{k}_sim"] << v if context.output_hash["subject_geo_#{k}_sim"]
                  end
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
              bbox = nil if bbox == '-180.0 -90.0 180.0 90.0' # don't want 'whole world' bboxes
              bbox_to_env = bbox ? Curator::Parsers::GeoParser.bbox_formatter(bbox, 'wkt_envelope') : nil
              context.output_hash['subject_bbox_geospatial'] << bbox_to_env
              context.output_hash['subject_coordinates_geospatial'] << bbox_to_env

              next unless coords || bbox

              geojson_hash = { type: 'Feature', geometry: {} }
              if bbox
                geojson_hash[:bbox] = bbox.split(' ').map(&:to_f)
                geojson_hash[:geometry][:type] = 'Polygon'
                geojson_hash[:geometry][:coordinates] = [
                  Curator::Parsers::GeoParser.bbox_formatter(bbox, 'wkt_array')
                ]
              elsif coords
                geojson_hash[:geometry][:type] = 'Point'
                geojson_hash[:geometry][:coordinates] = coords.split(',').reverse.map(&:to_f)
              end
              geojson_hash[:properties] = { placename: display_placename } if display_placename
              context.output_hash['subject_geojson_facet_ssim'] << geojson_hash.to_json
            end
            geo_fields.each { |geo_field| context.output_hash[geo_field].uniq! }
          end
        end
      end
    end
  end
end
