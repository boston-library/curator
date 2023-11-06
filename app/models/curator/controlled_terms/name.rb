# frozen_string_literal: true

module Curator
  class ControlledTerms::Name < ControlledTerms::Nomenclature
    include ControlledTerms::AuthorityDelegation
    include ControlledTerms::Canonicable
    include ControlledTerms::ReindexDescriptable
    include ControlledTerms::IdFromAuthUniqueValidatable
    include Mappings::MappedTerms

    VALID_NAME_TYPES = %w(personal corporate conference family).freeze

    belongs_to :authority, inverse_of: :names, class_name: 'Curator::ControlledTerms::Authority', optional: true

    has_many :desc_name_roles, inverse_of: :name, class_name: 'Curator::Mappings::DescNameRole', foreign_key: :name_id, dependent: :destroy
    has_many :physical_locations_of, inverse_of: :physical_location, class_name: 'Curator::Metastreams::Descriptive', foreign_key: :physical_location_id, dependent: :destroy

    validates :label, presence: true
    validates :name_type, inclusion: { in: VALID_NAME_TYPES }, allow_nil: true

    attr_json :affiliation, :string
    attr_json :name_type, :string
  end
end
