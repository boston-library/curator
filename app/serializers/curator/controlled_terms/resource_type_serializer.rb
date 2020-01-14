# frozen_string_literal: true

module Curator
  class ControlledTerms::ResourceTypeSerializer < ControlledTerms::NomenclatureSerializer
    schema_as_json root: :resource_type do
      attributes :authority_code
    end
  end
end
