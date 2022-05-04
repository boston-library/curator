# frozen_string_literal: true

module Curator
  class Metastreams::PlaceModsPresenter
    # This class acts as a wrapper for serializing <mods:originInfo><mods:place><mods:placeTerm> elements/attributes
    # Subclass PlaceTerm[Struct] - used as value object
    # PlaceTerm#initialize
    # @param[required] :label [String]
    # @param[required] :type [String]
    # @return [Curator::Metastreams::PlaceModsPresenter::PlaceTerm] instance
    PlaceTerm = Struct.new(:label, :type, keyword_init: true)

    attr_reader :place_term
    #
    # @param[required] place_of_publication [String]
    # @returns [Curator::Metastreams::PlaceModsPresenter] instance
    def initialize(place_of_publication)
      @place_term = PlaceTerm.new(label: place_of_publication, type: 'text')
    end
  end
end
