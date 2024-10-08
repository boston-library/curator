# frozen_string_literal: true

module Curator
  class ControlledTerms::Language < ControlledTerms::Nomenclature
    include ControlledTerms::AuthorityDelegation
    include ControlledTerms::ReindexDescriptable
    include ControlledTerms::IdFromAuthFindable
    include ControlledTerms::IdFromAuthUniqueValidatable
    include Mappings::MappedTerms
    belongs_to :authority, inverse_of: :languages, class_name: 'Curator::ControlledTerms::Authority'

    validates :label, :id_from_auth, presence: true
  end
end
