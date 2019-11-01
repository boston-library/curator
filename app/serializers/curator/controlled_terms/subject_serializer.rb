# frozen_string_literal: true

module Curator
  class ControlledTerms::SubjectSerializer < ControlledTerms::NomenclatureSerializer
    attributes :authority_code
  end
end
