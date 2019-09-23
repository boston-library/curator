# frozen_string_literal: true
module CommonwealthCurator
  class ControlledTerms::Name < ControlledTerms::Nomenclature
    include ControlledTerms::AuthorityDelegation
    include ControlledTerms::Cannonicable
    include Mappings::Mappable
    belongs_to :authority, class_name: 'CommonwealthCurator::ControlledTerms::Authority', foreign_key: :authority_id, inverse_of: :names, optional: true
    has_many :descriptive_name_roles, inverse_of: :name, class_name: 'CommonwealthCurator::Metastreams::DescNameRoleMapping', foreign_key: :name_id
    has_many :is_physical_location_of, inverse_of: :physical_location, class_name: 'CommonwealthCurator::Metastreams::Descriptive', foreign_key: :physical_location_id

    validates :label, presence: true

    attr_json :affiliation, :string
    attr_json :name_type, :string
  end
end
