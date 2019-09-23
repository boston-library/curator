# frozen_string_literal: true
module CommonwealthCurator
  class ControlledTerms::Language < ControlledTerms::Nomenclature
    include ControlledTerms::AuthorityDelegation
    include ControlledTerms::Cannonicable
    include Mappings::Mappable
    belongs_to :authority, class_name: 'CommonwealthCurator::ControlledTerms::Authority', foreign_key: :authority_id, inverse_of: :languages

    validates :label, :id_from_auth, presence: true
  end
end
