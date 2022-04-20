# frozen_string_literal: true

module Curator
  class DescriptiveFieldSets::CartographicModsPresenter
    attr_reader :scale, :projection, :bounding_box, :coordinates, :area_type

    def initialize(scale: nil, projection: nil, bounding_box: nil, area_type: nil)
      @scale = scale
      @projection = projection
      @bounding_box = bounding_box
      @area_type = area_type
    end

    def blank?
      scale.blank && projection.blank? && bounding_box.blank? && area_type.blank?
    end
  end
end
