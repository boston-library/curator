# frozen_string_literal: true
module CommonwealthCurator
  class ControlledTerms::Subject < ControlledTerms::Nomenclature
    include ControlledTerms::AuthorityDelegation
    include ControlledTerms::Cannonicable
    belongs_to :authority, class_name: 'CommonwealthCurator::ControlledTerms::Authority', foreign_key: :authority_id, inverse_of: :subjects, optional: true

    validates :label, presence: true
  end
end
