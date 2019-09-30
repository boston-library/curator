# frozen_string_literal: true
module Curator
  class ControlledTerms::Role < ControlledTerms::Nomenclature
    include ControlledTerms::AuthorityDelegation
    include ControlledTerms::Cannonicable
    include Mappings::Mappable
    belongs_to :authority, class_name: ControlledTerms.authority_class.to_s, inverse_of: :resource_types

    has_many :descriptive_name_roles, inverse_of: :role, class_name: Curator.mappings.desc_name_role_class.to_s, foreign_key: :role_id

    validates :label, :id_from_auth, presence: true
  end
end
