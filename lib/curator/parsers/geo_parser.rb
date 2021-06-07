# frozen_string_literal: true

module Curator
  module Parsers
    # methods for working with geographic data
    class GeoParser
      ##
      # take a bounding box and return in various WKT type syntax
      # @param bbox [String] bbox string: minX minY maxX maxY ("-87.6 41.7 -87.5 41.8")
      # @param output_format [String] 'wkt_polygon' || 'wkt_envelope'
      # @return [String || Array] depends on output_format param
      def self.bbox_formatter(bbox, output_format)
        coords_array = bbox.split(' ').map(&:to_f)
        min_x = coords_array[0]
        min_y = coords_array[1]
        max_x = coords_array[2]
        max_y = coords_array[3]
        case output_format
        when 'wkt_array' # used for geojson bounding box
          min_x, max_x = bbox_dateline_fix(min_x, max_x) if min_x > max_x
          coords_to_wkt_polygon(min_x, min_y, max_x, max_y)
        when 'wkt_envelope' # used for subject_bbox_geospatial field
          wkt_e_coords = normalize_bbox(min_x, min_y, max_x, max_y)
          "ENVELOPE(#{wkt_e_coords[0]}, #{wkt_e_coords[2]}, #{wkt_e_coords[3]}, #{wkt_e_coords[1]})"
        when 'wkt_polygon' # may need if we use Solr JTS for _geospatial field
          wkt_polygon = coords_to_wkt_polygon(min_x, min_y, max_x, max_y)
          wkt_order_strings = wkt_polygon.map { |wkt_p_coords| "#{wkt_p_coords[0]} #{wkt_p_coords[1]}" }
          "POLYGON((#{wkt_order_strings.join(', ')}))"
        else
          Rails.logger.error("UNSUPPORTED BBOX OUTPUT REQUESTED: '#{output_format}'")
        end
      end

      ##
      # return array of coordinate arrays corresponding to a WKT polygon
      # @param min_x [Float] minimum longitude
      # @param min_y [Float] minimum latitude
      # @param max_x [Float] maximum longitude
      # @param max_y [Float] maximum latitude
      # @return [Array]
      def self.coords_to_wkt_polygon(min_x, min_y, max_x, max_y)
        [[min_x, min_y],
         [max_x, min_y],
         [max_x, max_y],
         [min_x, max_y],
         [min_x, min_y]]
      end

      ##
      # checks and fixes any 'out of bounds' latitude values
      # sometimes passed from NBLMC georeferencing process
      # or Solr throws error: not in boundary Rect(minX=-180.0,maxX=180.0,minY=-90.0,maxY=90.0)
      # @param min_x [Float] minimum longitude
      # @param min_y [Float] minimum latitude
      # @param max_x [Float] maximum longitude
      # @param max_y [Float] maximum latitude
      # @return [Array]
      def self.normalize_bbox(min_x, min_y, max_x, max_y)
        min_x = (min_x + 360) if min_x < -180
        min_y = -90.0 if min_y < -90
        max_x = (max_x - 360) if max_x > 180
        max_y = 90.0 if max_y > 90
        [min_x, min_y, max_x, max_y]
      end

      ##
      # if this bbox crosses the dateline (min_x > max_x), have to adjust latitude values
      # so that bbox overlay displays properly in blacklight-maps views (Leaflet)
      # @param min_x [Float] minimum longitude
      # @param max_x [Float] maximum longitude
      # @return [Array]
      def self.bbox_dateline_fix(min_x, max_x)
        if min_x > 0
          degrees_to_add = 180 - min_x
          min_x = -(180 + degrees_to_add)
        elsif min_x < 0 && max_x < 0
          degrees_to_add = 180 + max_x
          max_x = 180 + degrees_to_add
        else
          Rails.logger.error("BBOX NOT PARSED CORRECTLY: min_x: #{min_x}, max_x: #{max_x}!")
        end
        [min_x, max_x]
      end

      ##
      # returns a well-formatted placename for display on a map
      # @param hgeo_hash [Hash] hash of <mods:hierarchicalGeographic> elements, e.g.:
      #   { continent: '', country: '', region: '', province: '', state: '', territory: '', county: '',
      #     island: '', city: '', city_section: '', area: '', extarea: '', other: '' }
      # @return [String]
      # rubocop:disable Metrics/CyclomaticComplexity
      def self.display_placename(hgeo_hash)
        placename = []
        placename[0] = hgeo_hash[:other] || hgeo_hash[:city_section] || hgeo_hash[:city] ||
                       hgeo_hash[:island] || hgeo_hash[:area]
        case hgeo_hash[:country]
        when 'United States', 'Canada'
          if hgeo_hash[:state] || hgeo_hash[:province]
            placename[0] ||= "#{hgeo_hash[:county]} (county)" if hgeo_hash[:county]
            if placename[0]
              placename[1] = Constants::STATE_ABBR.key(hgeo_hash[:state]) || hgeo_hash[:province]
            else
              placename[1] = hgeo_hash[:state] || hgeo_hash[:province]
            end
          else
            placename[0] ||= hgeo_hash[:region] || hgeo_hash[:territory] || hgeo_hash[:country]
          end
        else
          placename[0] ||= hgeo_hash[:state] || hgeo_hash[:province] || hgeo_hash[:region] || hgeo_hash[:territory]
          placename[0] ||= "#{hgeo_hash[:county]} (county)" if hgeo_hash[:county]
          placename[1] = hgeo_hash[:country]
        end
        placename.present? ? placename.join(', ').gsub(/(\A,\s)|(,\s\z)/, '') : nil
      end
      # rubocop:enable Metrics/CyclomaticComplexity

      ##
      # takes Geomash::Geonames data and makes it look like Geomash::TGN
      # @param hgeo_hash [Hash] e.g.:
      #   { area: '', cont: '', pcli: '', adm1: '', adm2: '', adm3: '', mt: '' }
      # @return [Hash]
      def self.normalize_geonames_hgeo(hgeo_hash)
        normalized = {}
        normalized[:continent] = hgeo_hash[:cont]
        normalized[:country] = hgeo_hash[:pcli]
        normalized[:state] = hgeo_hash[:adm1]
        normalized[:county] = hgeo_hash[:adm2]
        normalized[:city] = hgeo_hash[:adm3]
        last_value = hgeo_hash.values.last
        normalized[:other] = last_value unless normalized.value?(last_value)
        # clean data after dupe check above; use hgeo_hash values to avoid frozen string errors
        normalized[:county] = hgeo_hash[:adm2]&.gsub(/\sCounty\z/, '')
        normalized[:city] = hgeo_hash[:adm3]&.gsub(/\A(Town\sof|City\sof)\s/, '')
        normalized.compact
      end

      ##
      # takes Geomash::TGN data and output in correct hierarchical order
      # @param hgeo_hash [Hash] e.g.: { continent: '', country: '', ...}
      # @return [Hash]
      def self.normalize_tgn_hgeo(hgeo_hash)
        normalized = {}
        %i(continent country region province state territory county island city
           city_section area other).each do |k|
          normalized[k] = hgeo_hash[k]
        end
        normalized.compact
      end

      private_class_method :coords_to_wkt_polygon, :normalize_bbox, :bbox_dateline_fix
    end
  end
end
