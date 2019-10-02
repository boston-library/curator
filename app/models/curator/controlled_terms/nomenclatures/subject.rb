# frozen_string_literal: true
module Curator
  module ControlledTerms
    class Subject < Nomenclature
      include ControlledTerms::AuthorityDelegation
      include ControlledTerms::Cannonicable
      include Mappings::Mappable
      belongs_to :authority, class_name: ControlledTerms.authority_class.to_s, inverse_of: :subjects, optional: true

      validates :label, presence: true
    end
  end
end
