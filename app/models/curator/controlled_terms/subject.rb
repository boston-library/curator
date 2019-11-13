# frozen_string_literal: true

module Curator
  class ControlledTerms::Subject < ControlledTerms::Nomenclature
    include ControlledTerms::AuthorityDelegation
    include ControlledTerms::Cannonicable
    include Mappings::Mappable
    belongs_to :authority, inverse_of: :subjects, class_name: ControlledTerms.authority_class_name, optional: true

    validates :label, presence: true
  end
end
