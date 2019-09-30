# frozen_string_literal: true
module Curator
  class ControlledTerms::Geographic < ControlledTerms::Nomenclature
    include ControlledTerms::AuthorityDelegation
    include ControlledTerms::Cannonicable
    include Mappings::Mappable

    belongs_to :authority, inverse_of: :geographics, class_name: ControlledTerms.authority_class.to_s, optional: true

    has_many :institution_locations, inverse_of: :location, class_name: Curator.institution_class.to_s, foreign_key: :location_id, dependent: :nullify

    attr_json :area_type, :string
    attr_json :coordinates, :string
    attr_json :bounding_box, :string
  end
end
