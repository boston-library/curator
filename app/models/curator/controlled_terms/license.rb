# frozen_string_literal: true

module Curator
  class ControlledTerms::License < ControlledTerms::Nomenclature
    include ControlledTerms::ReindexDescriptable
    undef_method :desc_terms # Removed relation method since License is not a a valid Term to be mapped
    belongs_to :authority, class_name: 'Curator::ControlledTerms::Authority', optional: true
    # NOTE These don't really have authorities but this line is required so rails doesn't try to validate this relationship
    # ALSO I did not specify an inverse_of on either relationship so these should be hidden from authorities

    has_many :licensees, inverse_of: :license, class_name: 'Curator::Metastreams::Descriptive', foreign_key: :license_id, dependent: :destroy

    attr_json :uri, :string

    validates :label, presence: true
    validates :uri, format: { with: URI.regexp(%w(http https)), allow_blank: true }
  end
end
