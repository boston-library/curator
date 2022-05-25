# frozen_string_literal: true

module Curator
  class DescriptiveFieldSets::CartographicModsPresenter
    # For <mods:geographic><mods:cartographics> elements
    attr_reader :scale, :projection, :bounding_box, :cartesian_coords, :area_type
    # @param[optional] projection [String]
    # @param[optional] bounding_box [String]
    # @param[optional] coordinates [String]
    # @param[optional] area_type [String]
    # @param[optional] scale [Array[String]]
    # @return [Curator::DescriptiveFieldSets::CartographicModsPresenter] instance
    def initialize(projection: nil, bounding_box: nil, area_type: nil, coordinates: nil, scale: [])
      @projection = projection
      @bounding_box = bounding_box
      @area_type = area_type
      @cartesian_coords = coordinates
      @scale = scale
    end

    def coordinates
      return [] if bounding_box.blank? && cartesian_coords.blank?

      Array.wrap(bounding_box) + Array.wrap(cartesian_coords)
    end

    # @return [Boolean] - Needed for serializer
    def blank?
      %i(projection bounding_box area_type cartesian_coords scale).all? { |attr| public_send(attr).blank? }
    end
  end
end
