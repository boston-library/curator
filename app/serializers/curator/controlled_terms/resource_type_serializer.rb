# frozen_string_literal: true

module Curator
  class ControlledTerms::ResourceTypeSerializer < ControlledTerms::NomenclatureSerializer
    attributes :authority_code
  end
end
