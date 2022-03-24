# frozen_string_literal: true

module Curator
  class ControlledTerms::SubjectSerializer < ControlledTerms::NomenclatureSerializer
    build_schema_as_json do
      root_key :subject, :subjects

      include Curator::ControlledTerms::JsonSubject
    end
  end
end
