# frozen_string_literal: true

module Curator
  class ControlledTerms::LanguageSerializer < ControlledTerms::NomenclatureSerializer
    schema_as_json root: :language do
      attributes :authority_code
    end
  end
end
