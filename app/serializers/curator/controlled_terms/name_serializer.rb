# frozen_string_literal: true

module Curator
  class ControlledTerms::NameSerializer < ControlledTerms::NomenclatureSerializer
    schema_as_json root: :name do
      attributes :affiliation, :authority_code
      attribute(:type) { |record| record.name_type }
    end
  end
end
