# frozen_string_literal: true

module Curator
  class Metastreams::AdministrativeSerializer < CuratorSerializer
    attributes :description_standard, :flagged, :harvestable

    attribute :destination_site do
      object.destination_site.as_json
    end
  end
end
