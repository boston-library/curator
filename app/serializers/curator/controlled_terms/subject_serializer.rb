# frozen_string_literal: true

module Curator
  class ControlledTerms::SubjectSerializer < ControlledTerms::NomenclatureSerializer
    build_schema_as_json do
      root_key :subject, :subjects

      attributes :authority_code
    end
  end
end
