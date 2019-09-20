# frozen_string_literal: true
module CommonwealthCurator
  class ControlledTerms::Nomenclature < ApplicationRecord
    self.abstract_class = false

    include AttrJson::Record
    include AttrJson::Record::Dirty
    include AttrJson::Record::QueryScopes

    attr_json_config(default_container_attribute: :term_data)

    attr_json :label, :string
    attr_json :id_from_auth, :string

    validates :type, presence: true, inclusion: { in: ControlledTerms::ALLOWED_NOM_TYPES.collect{|type| "CommonwealthCurator::ControlledTerms::#{type}"} }
  end
end
