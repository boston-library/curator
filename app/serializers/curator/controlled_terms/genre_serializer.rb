# frozen_string_literal: true
module Curator
  class ControlledTerms::GenreSerializer < ControlledTerms::NomenclatureSerializer
    attributes :basic, :authority_code
  end
end
