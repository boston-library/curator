# frozen_string_literal: true

module Curator
  class ControlledTerms::Genre < ControlledTerms::Nomenclature
    include ControlledTerms::AuthorityDelegation
    include ControlledTerms::Canonicable
    include Mappings::MappedTerms

    belongs_to :authority, inverse_of: :genres, class_name: 'Curator::ControlledTerms::Authority', optional: true

    validates :label, presence: true

    attr_json :basic, :boolean, default: false

    scope :basic_genres, -> { jsonb_contains(basic: true) }
    scope :specific_genres, -> { jsonb_contains(basic: false) }
  end
end
