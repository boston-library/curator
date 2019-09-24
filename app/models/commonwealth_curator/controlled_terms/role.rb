# frozen_string_literal: true
module CommonwealthCurator
  class ControlledTerms::Role < ControlledTerms::Nomenclature
    include ControlledTerms::AuthorityDelegation
    include ControlledTerms::Cannonicable
    include Mappings::Mappable
    belongs_to :authority, class_name: 'CommonwealthCurator::ControlledTerms::Authority', foreign_key: :authority_id, inverse_of: :resource_types

    has_many :descriptive_name_roles, inverse_of: :role, class_name: 'CommonwealthCurator::Metastreams::DescriptiveNameRole', foreign_key: :role_id 

    validates :label, :id_from_auth, presence: true
  end
end
