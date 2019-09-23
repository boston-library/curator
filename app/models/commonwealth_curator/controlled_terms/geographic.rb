# frozen_string_literal: true
module CommonwealthCurator
  class ControlledTerms::Geographic < ControlledTerms::Nomenclature
    include ControlledTerms::AuthorityDelegation
    include ControlledTerms::Cannonicable
    include Mappings::Mappable
    belongs_to :authority, class_name: 'CommonwealthCurator::ControlledTerms::Authority', foreign_key: :authority_id, inverse_of: :geographics, optional: true

    attr_json :area_type, :string
    attr_json :coordinates, :string
    attr_json :bounding_box, :string
  end
end
