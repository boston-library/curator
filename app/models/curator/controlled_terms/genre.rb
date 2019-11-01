# frozen_string_literal: true

module Curator
  class ControlledTerms::Genre < ControlledTerms::Nomenclature
    include ControlledTerms::AuthorityDelegation
    include ControlledTerms::Cannonicable
    include Mappings::Mappable

    belongs_to :authority, inverse_of: :genres, class_name: ControlledTerms.authority_class_name, optional: true

    validates :label, presence: true

    attr_json :basic, :boolean, default: false

    scope :basic, -> { jsonb_contains(basic: true) }
    scope :specific, -> { jsonb_contains(basic: false) }
  end
end
