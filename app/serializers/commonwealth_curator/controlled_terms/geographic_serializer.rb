# frozen_string_literal: true
module CommonwealthCurator
  class ControlledTerms::GeographicSerializer < ControlledTerms::NomenclatureSerializer
    attributes :area_type, :coordinates, :bounding_box, :authority_code
  end
end
