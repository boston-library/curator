# frozen_string_literal: true
module Curator
  class ControlledTerms::NameSerializer < ControlledTerms::NomenclatureSerializer
    attributes :affiliation, :authority_code
    attribute :name_type, key: :type
  end
end
