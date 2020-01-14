# frozen_string_literal: true

module Curator
  class ControlledTerms::RoleSerializer < ControlledTerms::NomenclatureSerializer
    schema_as_json root: :role do
      attributes :authority_code
    end
  end
end
