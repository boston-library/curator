# frozen_string_literal: true

module Curator
  class ControlledTerms::RightsStatementSerializer < ControlledTerms::NomenclatureSerializer
    schema_as_json root: :rights_statement do
      attributes :uri
    end
  end
end
