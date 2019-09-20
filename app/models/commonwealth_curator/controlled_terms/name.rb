# frozen_string_literal: true
module CommonwealthCurator
  class ControlledTerms::Name < ControlledTerms::Nomenclature
    belongs_to :authority, class_name: 'ControlledTerms::Authority', foreign_key: :authority_id, inverse_of: :names, optional: true

    # has_many :descriptive_name_roles, inverse_of: :name, class_name: "Metastreams::DescriptiveNameRole", foreign_key: :name_id
    # has_many :physical_location_descriptives, inverse_of: :physical_location, class_name: 'Metastreams::Descriptive', foreign_key: :physical_location_id

    validates :label, presence: true

    attr_json :affiliation, :string
    attr_json :name_type, :string
  end
end
