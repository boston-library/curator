# frozen_string_literal: true

module Curator
  class ControlledTerms::GenreSerializer < ControlledTerms::NomenclatureSerializer
    build_schema_as_json do
      root_key :genre, :genres

      include Curator::ControlledTerms::GenreJson
    end
  end
end
