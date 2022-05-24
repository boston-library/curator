# frozen_string_literal: true

module Curator
  class Metastreams::AdministrativeSerializer < Curator::Serializers::AbstractSerializer
    build_schema_as_json do
      root_key :administrative, :administratives

      include Curator::Metastreams::AdministratableJson
    end
  end
end
