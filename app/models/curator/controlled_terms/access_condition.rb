# frozen_string_literal: true

module Curator
  class ControlledTerms::AccessCondition < ControlledTerms::Nomenclature
    include ControlledTerms::ReindexDescriptable
    undef_method :desc_terms # Removed relation method since these are not a valid Term to be mapped
    belongs_to :authority, class_name: 'Curator::ControlledTerms::Authority', optional: true
    # NOTE These don't really have authorities but this line is required so rails doesn't try to validate this relationship
    # ALSO I did not specify an inverse_of on either relationship so these should be hidden from authorities

    attr_json :uri, :string

    validates :label, presence: true
  end
end
