# frozen_string_literal: true

module Curator
  class Metastreams::PlaceModsPresenter
    # This class acts as a wrapper for serializing <mods:originInfo><mods:place><mods:placeTerm> elements/attributes
    PLACE_TERM_MODS_TYPE = 'text'
    # Subclass PlaceTerm[Struct] - used as value object
    # PlaceTerm#initialize
    # @param :label [String]
    # @param :type [String]
    # @return [Curator::Metastreams::PlaceModsPresenter::PlaceTerm] instance
    PlaceTerm = Struct.new(:label, :type, keyword_init: true)

    attr_reader :place_term
    # @param[required] place_of_publication [String]
    # @return [Curator::Metastreams::PlaceModsPresenter] instance
    def initialize(place_of_publication)
      @place_term = PlaceTerm.new(label: place_of_publication, type: PLACE_TERM_MODS_TYPE)
    end
  end
end
