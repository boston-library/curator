# frozen_string_literal: true

module Curator
  class ControlledTerms::RoleSerializer < ControlledTerms::NomenclatureSerializer
    build_schema_as_json do
      root_key :role, :roles

      include Curator::ControlledTerms::JsonRole
    end
  end
end
