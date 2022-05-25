# frozen_string_literal: true

module Curator
  class ControlledTerms::NameSerializer < ControlledTerms::NomenclatureSerializer
    build_schema_as_json do
      root_key :name, :names

      include Curator::ControlledTerms::NameJson
    end
  end
end
