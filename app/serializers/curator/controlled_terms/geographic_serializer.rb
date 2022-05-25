# frozen_string_literal: true

module Curator
  class ControlledTerms::GeographicSerializer < ControlledTerms::NomenclatureSerializer
    build_schema_as_json do
      root_key :geographic, :geographics

      include Curator::ControlledTerms::GeographicJson
    end
  end
end
