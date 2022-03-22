# frozen_string_literal: true

module Curator
  class ControlledTerms::NomenclatureSerializer < Curator::Serializers::AbstractSerializer
    build_schema_as_json do
      include Curator::ControlledTerms::JsonNomenclature
    end
  end
end
