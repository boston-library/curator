# frozen_string_literal: true

module Curator
  class ControlledTerms::LicenseSerializer < ControlledTerms::NomenclatureSerializer
    build_schema_as_json do
      root_key :license, :licenses

      include Curator::ControlledTerms::JsonLicense
    end
  end
end
