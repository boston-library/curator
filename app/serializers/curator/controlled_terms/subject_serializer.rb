# frozen_string_literal: true

module Curator
  class ControlledTerms::SubjectSerializer < ControlledTerms::NomenclatureSerializer
    schema_as_json root: :subject do
      attributes :authority_code
    end
  end
end
