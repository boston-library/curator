# frozen_string_literal: true

module Curator
  class DescriptiveFieldSets::CartographicModsPresenter
    attr_reader :scale, :projection, :bounding_box, :cartesian_coords, :area_type

    # For <mods:cartographics> elements
    # @param[optional] scale [Array[String]]
    # @param[optional] projection [String]
    # @param[optional] bounding_box [String]
    # @param[optional] coordinates [String]
    # @param[optional] area_type []
    # @return [Curator::DescriptiveFieldSets::CartographicModsPresenter] instance

    def initialize(scale: [], projection: nil, bounding_box: nil, area_type: nil, coordinates: nil)
      @scale = scale
      @projection = projection
      @bounding_box = bounding_box
      @area_type = area_type
      @cartesian_coords = coordinates
    end

    def coordinates
      return [] if bounding_box.blank? && cartesian_coords.blank?

      Array.wrap(bounding_box) + Array.wrap(cartesian_coords)
    end

    def blank?
      %i(scale projection bounding_box area_type cartesian_coords).all? { |attr| public_send(attr).blank? }
    end
  end
end
