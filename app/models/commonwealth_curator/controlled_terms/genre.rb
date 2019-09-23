# frozen_string_literal: true
module CommonwealthCurator
  class ControlledTerms::Genre < ControlledTerms::Nomenclature
    include ControlledTerms::AuthorityDelegation
    include ControlledTerms::Cannonicable
    
    belongs_to :authority, class_name: 'CommonwealthCurator::ControlledTerms::Authority', foreign_key: :authority_id, inverse_of: :genres, optional: true

    validates :label, presence: true

    attr_json :basic, :boolean, default: false

    scope :basic, -> { jsonb_contains(basic: true) }
    scope :specific, -> { jsonb_contains(basic: false) }
  end
end
