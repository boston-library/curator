# frozen_string_literal: true

module Curator
  class ControlledTerms::GenreSerializer < ControlledTerms::NomenclatureSerializer
    schema_as_json root: :genre do
      attributes :basic, :authority_code
    end
  end
end
