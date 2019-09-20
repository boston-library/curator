# frozen_string_literal: true
module CommonwealthCurator
  class ControlledTerms::NomenclatureSerializer < ApplicationSerializer
    attributes :label, :id_from_auth
  end
end
