# frozen_string_literal: true
module CommonwealthCurator
  class ControlledTerms::GenreSerializer < ControlledTerms::NomenclatureSerializer
    attributes :basic, :authority_code
  end
end
