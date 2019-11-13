# frozen_string_literal: true

module Curator
  class ControlledTerms::Role < ControlledTerms::Nomenclature
    include ControlledTerms::AuthorityDelegation
    include ControlledTerms::Cannonicable
    include Mappings::Mappable
    belongs_to :authority, inverse_of: :roles, class_name: ControlledTerms.authority_class_name

    has_many :desc_name_roles, inverse_of: :role, class_name: Curator.mappings.desc_name_role_class_name, foreign_key: :role_id, dependent: :destroy

    validates :label, :id_from_auth, presence: true
  end
end
