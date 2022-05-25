# frozen_string_literal: true

module Curator
  class ControlledTerms::ResourceTypeSerializer < ControlledTerms::NomenclatureSerializer
    build_schema_as_json do
      root_key :resource_type, :resource_types

      include Curator::ControlledTerms::ResourceTypeJson
    end
  end
end
