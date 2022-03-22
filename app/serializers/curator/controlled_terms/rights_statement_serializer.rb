# frozen_string_literal: true

module Curator
  class ControlledTerms::RightsStatementSerializer < ControlledTerms::NomenclatureSerializer
    build_schema_as_json do
      root_key :rights_statement, :rights_statements

      include Curator::ControlledTerms::JsonRightsStatement
    end
  end
end
