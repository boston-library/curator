# frozen_string_literal: true

module Curator
  class Metastreams::HoldingSimpleModsPresenter
    # For serializing <mods:location><mods:holdingSimple> elements
    #
    ## Subclass CopyInformation[Struct]
    ## This Struct is for serializing <mods:location><mods:holdingSimple><mods:copyInformation> elements
    ## CopyInformation#initialize
    ## @param[optional] :sub_location [String | nil]
    ## @param[optional] :shelf_locator [String | nil]
    ## @return [Curator::Metastreams::HoldingSimpleModsPresenter::CopyInformation] instance
    CopyInformation = Struct.new(:sub_location, :shelf_locator, keyword_init: true)

    attr_reader :copy_information

    # @param[optional] :sub_location [String | nil]
    # @param[optional] :shelf_locator [String | nil]
    # @return [Curator::Metastreams::HoldingSimpleModsPresenter] instance
    def initialize(sub_location: nil, shelf_locator: nil)
      @copy_information = CopyInformation.new(sub_location: sub_location, shelf_locator: shelf_locator)
    end

    # @return [Boolean] - Needed for serializer
    def blank?
      copy_information.sub_location.blank? && copy_information.shelf_locator.blank?
    end
  end
end
