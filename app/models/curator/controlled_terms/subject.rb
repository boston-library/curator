# frozen_string_literal: true

module Curator
  class ControlledTerms::Subject < ControlledTerms::Nomenclature
    include ControlledTerms::AuthorityDelegation
    include ControlledTerms::Canonicable
    include ControlledTerms::ReindexDescriptable
    include ControlledTerms::IdFromAuthFindable
    include ControlledTerms::IdFromAuthUniqueValidatable
    include Mappings::MappedTerms
    belongs_to :authority, inverse_of: :subjects, class_name: 'Curator::ControlledTerms::Authority', optional: true

    validates :label, presence: true
  end
end
