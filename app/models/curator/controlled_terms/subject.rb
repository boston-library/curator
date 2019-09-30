# frozen_string_literal: true
module Curator
  class ControlledTerms::Subject < ControlledTerms::Nomenclature
    include ControlledTerms::AuthorityDelegation
    include ControlledTerms::Cannonicable
    include Mappings::Mappable
    belongs_to :authority, class_name: 'Curator::ControlledTerms::Authority', foreign_key: :authority_id, inverse_of: :subjects, optional: true

    validates :label, presence: true
  end
end
