# frozen_string_literal: true
module Curator
  class ControlledTerms::Name < ControlledTerms::Nomenclature
    include ControlledTerms::AuthorityDelegation
    include ControlledTerms::Cannonicable
    include Mappings::Mappable

    belongs_to :authority, inverse_of: :names, class_name: ControlledTerms.authority_class.to_s, optional: true

    has_many :descriptive_name_roles, inverse_of: :name, class_name: Curator.mappings.desc_name_role_class.to_s, foreign_key: :name_id
    has_many :physical_locations_of, inverse_of: :physical_location, class_name: Curator.metastreams.descriptive_class.to_s, foreign_key: :physical_location_id

    validates :label, presence: true

    attr_json :affiliation, :string
    attr_json :name_type, :string
  end
end
