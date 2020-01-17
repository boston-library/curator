# frozen_string_literal: true

module Curator
  class ControlledTerms::Nomenclature < ApplicationRecord
    include AttrJson::Record
    include AttrJson::Record::Dirty
    include AttrJson::Record::QueryScopes
    include Mappings::MappedTerms

    attr_json_config(default_container_attribute: :term_data)

    attr_json :label, :string
    attr_json :id_from_auth, :string

    validates :type, presence: true, inclusion: { in: ControlledTerms.nomenclature_types.collect { |type| "Curator::ControlledTerms::#{type}" } }
  end
end
