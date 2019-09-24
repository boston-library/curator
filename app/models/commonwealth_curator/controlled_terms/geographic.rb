# frozen_string_literal: true
module CommonwealthCurator
  class ControlledTerms::Geographic < ControlledTerms::Nomenclature
    include ControlledTerms::AuthorityDelegation
    include ControlledTerms::Cannonicable
    include Mappings::Mappable

    belongs_to :authority, inverse_of: :geographics, class_name: 'CommonwealthCurator::ControlledTerms::Authority', optional: true

    has_many :instititution_locations, inverse_of: :location, class_name: 'CommonwealthCurator::Institution', foreign_key: :location_id, dependent: :destroy

    attr_json :area_type, :string
    attr_json :coordinates, :string
    attr_json :bounding_box, :string
  end
end
