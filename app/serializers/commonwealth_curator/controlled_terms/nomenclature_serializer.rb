# frozen_string_literal: true
module CommonwealthCurator
  class ControlledTerms::NomenclatureSerializer < CuratorSerializer
    attributes :label, :id_from_auth
  end
end
