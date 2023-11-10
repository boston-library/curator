# frozen_string_literal: true

module Curator
  class DescriptiveFieldSets::CartographicModsPresenter
    # @param :projection [String]
    # @param :scale [Array[String]]
    # @return [Array[Curator::DescriptiveFieldSets::CartographicModsPresenter]]
    def self.wrap_multiple(projection: nil, scale: [])
      cart_attrs = []
      cart_attrs << { projection: projection } if projection.present?
      cart_attrs += scale.map { |s| { scale: s } }
      cart_attrs.map { |cart_kwargs| new(**cart_kwargs) }
    end

    # For <mods:geographic><mods:cartographics> elements
    attr_reader :scale, :projection, :bounding_box, :cartesian_coords, :area_type
    # @param[optional] projection [String]
    # @param[optional] bounding_box [String]
    # @param[optional] coordinates [String]
    # @param[optional] area_type [String]
    # @param[optional] scale [String]
    # @return [Curator::DescriptiveFieldSets::CartographicModsPresenter] instance
    def initialize(projection: nil, bounding_box: nil, area_type: nil, coordinates: nil, scale: nil)
      @projection = projection
      @bounding_box = bounding_box
      @area_type = area_type
      @cartesian_coords = coordinates
      @scale = scale
    end

    def coordinates
      return if bounding_box.blank? && cartesian_coords.blank?

      return bounding_box if bounding_box.present?

      cartesian_coords
    end

    # @return [Boolean] - Needed for serializer
    def blank?
      %i(projection bounding_box area_type cartesian_coords scale).all? { |attr| public_send(attr).blank? }
    end
  end
end
