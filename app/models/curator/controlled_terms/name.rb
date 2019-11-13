# frozen_string_literal: true

module Curator
  class ControlledTerms::Name < ControlledTerms::Nomenclature
    include ControlledTerms::AuthorityDelegation
    include ControlledTerms::Cannonicable
    include Mappings::Mappable

    belongs_to :authority, inverse_of: :names, class_name: ControlledTerms.authority_class_name, optional: true

    has_many :desc_name_roles, inverse_of: :name, class_name: Curator.mappings.desc_name_role_class_name, foreign_key: :name_id, dependent: :destroy
    has_many :physical_locations_of, inverse_of: :physical_location, class_name: Curator.metastreams.descriptive_class_name, foreign_key: :physical_location_id, dependent: :destroy

    validates :label, presence: true

    attr_json :affiliation, :string
    attr_json :name_type, :string
  end
end
