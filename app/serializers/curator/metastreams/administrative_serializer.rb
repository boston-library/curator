# frozen_string_literal: true

module Curator
  class Metastreams::AdministrativeSerializer < Curator::Serializers::AbstractSerializer
    schema_as_json root: :administrative do
      attributes :description_standard, :flagged, :harvestable, :destination_site, :oai_header_id
    end
  end
end
