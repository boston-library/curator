# frozen_string_literal: true

module Curator
  class ControlledTerms::AccessConditionSerializer < Curator::Serializers::AbstractSerializer
    build_schema_as_json do
      include Curator::ControlledTerms::AccessConditionJson
    end
  end
end
