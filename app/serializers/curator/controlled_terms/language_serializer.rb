# frozen_string_literal: true

module Curator
  class ControlledTerms::LanguageSerializer < ControlledTerms::NomenclatureSerializer
    attributes :authority_code
  end
end
