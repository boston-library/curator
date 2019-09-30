# frozen_string_literal: true
module Curator
  class ControlledTerms::Nomenclature < ApplicationRecord
    ALLOWED_NOM_TYPES=%w(Genre Geographic Language License Name ResourceType Role Subject).freeze
    self.abstract_class = false
    include AttrJson::Record
    include AttrJson::Record::Dirty
    include AttrJson::Record::QueryScopes

    attr_json_config(default_container_attribute: :term_data)

    attr_json :label, :string
    attr_json :id_from_auth, :string

    validates :type, presence: true, inclusion: { in: ALLOWED_NOM_TYPES.collect{|type| "Curator::ControlledTerms::#{type}"} }
  end
end
