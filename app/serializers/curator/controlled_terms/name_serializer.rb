# frozen_string_literal: true

module Curator
  class ControlledTerms::NameSerializer < ControlledTerms::NomenclatureSerializer
    schema_as_json root: :name do
      attributes :affiliation, :authority_code, :name_type
    end
  end
end
