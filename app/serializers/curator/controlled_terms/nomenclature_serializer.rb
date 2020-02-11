# frozen_string_literal: true

module Curator
  class ControlledTerms::NomenclatureSerializer < Curator::Serializers::AbstractSerializer
    schema_as_json do
      attributes :label, :id_from_auth
    end
  end
end
