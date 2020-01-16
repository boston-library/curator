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
          if min_x > max_x
            min_x, max_x = bbox_dateline_fix(min_x, max_x)
          end
          coords_to_wkt_polygon(min_x, min_y, max_x, max_y)
        when 'wkt_envelope' # used for subject_bbox_geospatial field
          coords = normalize_bbox(min_x, min_y, max_x, max_y)
          "ENVELOPE(#{coords[0]}, #{coords[2]}, #{coords[3]}, #{coords[1]})"
        when 'wkt_polygon' # may need if we use Solr JTS for _geospatial field
          wkt_polygon = coords_to_wkt_polygon(min_x, min_y, max_x, max_y)
          wkt_order_strings = wkt_polygon.map { |coords| "#{coords[0]} #{coords[1]}" }
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

      private_class_method :coords_to_wkt_polygon, :normalize_bbox, :bbox_dateline_fix
    end
  end
end
