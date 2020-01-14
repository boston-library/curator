# frozen_string_literal: true

module Curator
  class Metastreams::AdministrativeSerializer < CuratorSerializer
    schema_as_json root: :administrative do
      attributes :description_standard, :flagged, :harvestable, :destination_site
    end
  end
end
