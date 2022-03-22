# frozen_string_literal: true

module Curator
  class ControlledTerms::LanguageSerializer < ControlledTerms::NomenclatureSerializer
    build_schema_as_json do
      root_key :language, :languages

      include Curator::ControlledTerms::JsonLanguage
    end
  end
end
