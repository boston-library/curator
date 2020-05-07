# frozen_string_literal: true

module Curator
  class ControlledTerms::ResourceType < ControlledTerms::Nomenclature
    include ControlledTerms::AuthorityDelegation
    include ControlledTerms::ReindexDescriptable
    include Mappings::MappedTerms
    belongs_to :authority, inverse_of: :resource_types, class_name: 'Curator::ControlledTerms::Authority'

    validates :label, :id_from_auth, presence: true
  end
end
