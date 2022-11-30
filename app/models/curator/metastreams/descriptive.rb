# frozen_string_literal: true

module Curator
  class Metastreams::Descriptive < ApplicationRecord
    include AttrJson::Record
    include AttrJson::Record::QueryScopes
    include AttrJson::Record::Dirty
    include AttrJson::NestedAttributes

    has_paper_trail skip: %i(lock_version)

    enum digital_origin: {
      born_digital: 'born_digital',
      reformatted_digital: 'reformatted_digital',
      digitized_microfilm: 'digitized_microfilm',
      digitized_other_analog: 'digitized_other_analog'
    }.freeze

    enum text_direction: %w(ltr rtl).freeze
    # JSON ATTRS
    scope :with_physical_location, -> { includes(physical_location: :authority) }

    scope :with_license, -> { includes(:license) }

    scope :with_rights_statement, -> { includes(:rights_statement) }

    scope :with_desc_terms, lambda {
      eager_load(:desc_terms).includes(:genres, :resource_types, :languages, :subject_topics, :subject_names, :subject_geos)
    }

    scope :with_mappings, lambda {
      includes(:host_collections, name_roles: [:name, :role])
    }

    scope :for_serialization, -> { with_physical_location.with_license.with_mappings.with_desc_terms.with_rights_statement }

    scope :local_id_finder, -> (identifier) { jsonb_contains(identifier: identifier) }

    # NOTE: need to use attr json for array items
    # Identifier
    attr_json :identifier, DescriptiveFieldSets::Identifier.to_type, container_attribute: :identifier_json, array: true, default: []

    # Notes
    attr_json :note, DescriptiveFieldSets::Note.to_type, container_attribute: :note_json, array: true, default: []

    # NOTE: per changes in  attr_json 1.2 we can now use the built in #serialize method
    # #Title
    serialize :title, DescriptiveFieldSets::TitleSet.to_serialization_coder
    # Date
    serialize :date, DescriptiveFieldSets::Date.to_serialization_coder
    # Publication
    serialize :publication, DescriptiveFieldSets::Publication.to_serialization_coder
    # Related
    serialize :related, DescriptiveFieldSets::Related.to_serialization_coder

    # Cartographics
    serialize :cartographic, DescriptiveFieldSets::Cartographic.to_serialization_coder

    # Non REL Subjects
    serialize :subject_other, DescriptiveFieldSets::Subject.to_serialization_coder

    # RELS
    # PARENTS
    belongs_to :digital_object, inverse_of: :descriptive, class_name: 'Curator::DigitalObject', touch: true
    belongs_to :license, inverse_of: :licensees, class_name: 'Curator::ControlledTerms::License'
    belongs_to :physical_location, inverse_of: :physical_locations_of, class_name: 'Curator::ControlledTerms::Name'
    belongs_to :rights_statement, inverse_of: :rights_statement_of, class_name: 'Curator::ControlledTerms::RightsStatement', optional: true
    # MAPPING OBJECTS
    with_options inverse_of: :descriptive, dependent: :destroy, autosave: true do
      has_many :desc_terms, class_name: 'Curator::Mappings::DescTerm'
      has_many :name_roles, class_name: 'Curator::Mappings::DescNameRole'
      has_many :desc_host_collections, class_name: 'Curator::Mappings::DescHostCollection'
    end

    validates_associated :desc_terms, :name_roles, :desc_host_collections

    has_many :host_collections, through: :desc_host_collections, source: :host_collection do
      def names
        pluck(:name)
      end

      # NOTE: the as json is needed for specs
      def as_json(*)
        names.as_json
      end
    end

    # TERMS
    with_options through: :desc_terms, source: :mapped_term do
      has_many :genres, class_name: 'Curator::ControlledTerms::Genre'
      has_many :resource_types, class_name: 'Curator::ControlledTerms::ResourceType'
      has_many :languages, class_name: 'Curator::ControlledTerms::Language'
      has_many :subject_topics, class_name: 'Curator::ControlledTerms::Subject'
      has_many :subject_names, class_name: 'Curator::ControlledTerms::Name'
      has_many :subject_geos, class_name: 'Curator::ControlledTerms::Geographic'
    end

    # VALIDATIONS
    validates :digital_object_id, uniqueness: true
    validates :toc_url, format: { with: URI.regexp(%w(http https)), allow_blank: true }

    # DECORATOR METHODS
    # Subject Node in Serialzer using decorator

    def subject
      return @subject if defined?(@subject)

      @subject = Metastreams::SubjectDecorator.new(self)
    end
  end
end
