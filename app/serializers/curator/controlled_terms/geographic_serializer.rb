# frozen_string_literal: true

module Curator
  class ControlledTerms::GeographicSerializer < ControlledTerms::NomenclatureSerializer
    schema_as_json root: :geographic do
      attributes :area_type, :coordinates, :bounding_box, :authority_code
    end
  end
end
