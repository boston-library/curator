# frozen_string_literal: true

module Curator
  class DescriptiveFieldSets::CartographicModsPresenter
    attr_reader :scale, :projection, :bounding_box, :coordinates, :area_type

    # @param[optional] scale [Array[String]]
    # @param[optional] projection [String]
    # @param[optional] bounding_box [String]
    # @param[optional] area_type []
    # @return [Curator::DescriptiveFieldSets::CartographicModsPresenter] instance

    def initialize(scale: [], projection: nil, bounding_box: nil, area_type: nil, coordinates: nil)
      @scale = scale
      @projection = projection
      @bounding_box = bounding_box
      @area_type = area_type
      @coordinates = coordinates
    end

    def blank?
      scale.blank && projection.blank? && bounding_box.blank? && area_type.blank? && coordinates.blank?
    end
  end
end
