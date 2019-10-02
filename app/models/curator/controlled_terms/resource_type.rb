# frozen_string_literal: true
module Curator
  class ControlledTerms::ResourceType < ControlledTerms::Nomenclature
    include ControlledTerms::AuthorityDelegation
    include ControlledTerms::Cannonicable
    include Mappings::Mappable
    belongs_to :authority, inverse_of: :resource_types, class_name: ControlledTerms.authority_class_name

    validates :label, :id_from_auth, presence: true
  end
end
