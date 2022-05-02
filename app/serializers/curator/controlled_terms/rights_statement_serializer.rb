# frozen_string_literal: true

module Curator
  class ControlledTerms::RightsStatementSerializer < ControlledTerms::AccessConditionSerializer
    build_schema_as_json do
      root_key :rights_statement, :rights_statements
    end
  end
end
