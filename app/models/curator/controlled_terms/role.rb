# frozen_string_literal: true

module Curator
  class ControlledTerms::Role < ControlledTerms::Nomenclature
    include ControlledTerms::AuthorityDelegation
    include ControlledTerms::ReindexDescriptable
    include Mappings::MappedTerms
    belongs_to :authority, inverse_of: :roles, class_name: 'Curator::ControlledTerms::Authority'

    has_many :desc_name_roles, inverse_of: :role, class_name: 'Curator::Mappings::DescNameRole', foreign_key: :role_id, dependent: :destroy

    validates :label, :id_from_auth, presence: true
  end
end
