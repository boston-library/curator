# frozen_string_literal: true

module Curator
  class ControlledTerms::RoleSerializer < ControlledTerms::NomenclatureSerializer
    attributes :authority_code
  end
end
