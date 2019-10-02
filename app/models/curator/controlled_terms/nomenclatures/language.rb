# frozen_string_literal: true
module Curator
  module ControlledTerms
    class Language < Nomenclature
      include ControlledTerms::AuthorityDelegation
      include ControlledTerms::Cannonicable
      include Mappings::Mappable
      belongs_to :authority, inverse_of: :languages, class_name: ControlledTerms.authority_class.to_s

      validates :label, :id_from_auth, presence: true
    end
  end
end
