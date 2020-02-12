# frozen_string_literal: true

module Curator
  class ControlledTerms::Geographic < ControlledTerms::Nomenclature
    include ControlledTerms::AuthorityDelegation
    include ControlledTerms::Cannonicable
    include Mappings::MappedTerms

    belongs_to :authority, inverse_of: :geographics, class_name: 'Curator::ControlledTerms::Authority', optional: true

    has_many :institution_locations, inverse_of: :location, class_name: 'Curator::Institution', foreign_key: :location_id, dependent: :destroy

    attr_json :area_type, :string
    attr_json :coordinates, :string
    attr_json :bounding_box, :string
  end
end
