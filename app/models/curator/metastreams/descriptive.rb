# frozen_string_literal: true

module Curator
  class Metastreams::Descriptive < ApplicationRecord
    include AttrJson::Record
    include AttrJson::Record::QueryScopes
    include AttrJson::Record::Dirty
    include AttrJson::NestedAttributes

    enum digital_origin: ['born digital', 'reformatted digital', 'digitized microfilm', 'digitized other analog'].freeze
    enum text_direction: %w(ltr rtl).freeze
    # JSON ATTRS

    scope :with_mappings, -> { includes(:desc_terms, :name_roles, :desc_host_collections) }
    scope :with_physical_location, -> { includes(:physical_location) }
    scope :for_serialization, -> { merge(with_mappings).merge(with_physical_location) }
    # Identifier
    attr_json :identifier, Curator::Descriptives::Identifier.to_type, container_attribute: :identifier_json, array: true, default: []

    # #Title
    attr_json :title, Curator::Descriptives::TitleSet.to_type, container_attribute: :title_json

    # Notes
    attr_json :note, Curator::Descriptives::Note.to_type, container_attribute: :note_json, array: true, default: []

    # Date
    attr_json :date, Curator::Descriptives::Date.to_type, container_attribute: :date_json

    # Publication
    attr_json :publication, Curator::Descriptives::Publication.to_type, container_attribute: :publication_json

    # Related
    attr_json :related, Curator::Descriptives::Related.to_type, container_attribute: :related_json

    # Cartographics
    attr_json :cartographic, Curator::Descriptives::Cartographic.to_type, container_attribute: :cartographics_json

    # Non REL Subjects
    attr_json :subject_other, Curator::Descriptives::Subject.to_type, container_attribute: :subject_json

    # RELS
    # PARENTS
    belongs_to :descriptable, polymorphic: true, inverse_of: :descriptive
    belongs_to :physical_location, -> { merge(with_authority) }, inverse_of: :physical_locations_of, class_name: 'Curator::ControlledTerms::Name'

    # MAPPING OBJECTS
    with_options inverse_of: :descriptive, dependent: :destroy do
      has_many :desc_terms, -> { includes(:mapped_term) }, class_name: 'Curator::Mappings::DescTerm'
      has_many :name_roles, -> { includes(:name, :role) }, class_name: 'Curator::Mappings::DescNameRole'
      has_many :desc_host_collections, -> { includes(:host_collection) }, class_name: 'Curator::Mappings::DescHostCollection'
    end

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
      has_one :license, class_name: 'Curator::ControlledTerms::License'
      #This wont work through the ,map table. Think we should just map the license directly to the table instead

      has_many :genres, -> { merge(with_authority) }, class_name: 'Curator::ControlledTerms::Genre'
      has_many :resource_types, -> { merge(with_authority) }, class_name: 'Curator::ControlledTerms::ResourceType'
      has_many :languages, -> { merge(with_authority) }, class_name: 'Curator::ControlledTerms::Language'
      has_many :subject_topics, -> { merge(with_authority) }, class_name: 'Curator::ControlledTerms::Subject'
      has_many :subject_names, -> { merge(with_authority) }, class_name: 'Curator::ControlledTerms::Name'
      has_many :subject_geos, -> { merge(with_authority) }, class_name: 'Curator::ControlledTerms::Geographic'
    end

    # VALIDATIONS
    validates :descriptable_id, uniqueness: { scope: :descriptable_type }
    validates :descriptable_type, inclusion: { in: %w(Curator::DigitalObject) }
    validates :toc_url, format: { with: URI.regexp(%w(http https)), allow_blank: true }

    # DECORATOR METHODS
    # Subject Node in Serialzer using decorator

    def subject
      Metastreams::SubjectDecorator.new(self)
    end
  end
end
