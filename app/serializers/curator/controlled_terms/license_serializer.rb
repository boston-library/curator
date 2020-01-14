# frozen_string_literal: true

module Curator
  class ControlledTerms::LicenseSerializer < ControlledTerms::NomenclatureSerializer
    schema_as_json root: :license do
      attributes :uri
    end
  end
end
