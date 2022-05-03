# frozen_string_literal: true

module Curator
  class Metastreams::PlaceModsPresenter
    PlaceTerm = Struct.new(:label, :type, keyword_init: true)

    attr_reader :place_term

    def initialize(place_of_publication)
      @place_term = PlaceTerm.new(label: place_of_publication, type: 'text')
    end
  end
end
