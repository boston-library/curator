# frozen_string_literal: true

module Curator
  class ControlledTerms::LicenseSerializer < ControlledTerms::AccessConditionSerializer
    build_schema_as_json do
      root_key :license, :licenses
    end
  end
end
