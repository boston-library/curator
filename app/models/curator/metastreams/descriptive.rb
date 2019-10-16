# frozen_string_literal: true
module Curator
  class Metastreams::Descriptive < ApplicationRecord
    include AttrJson::Record
    include AttrJson::Record::QueryScopes
    include AttrJson::Record::Dirty
    include AttrJson::NestedAttributes

    enum digital_origin: ['born digital', 'reformatted digital', 'digitized microfilm', 'digitized other analog'].freeze
    enum origin_event: %w(production publication distribution manufacture).freeze
    enum text_direction: %w(ltr rtl).freeze
    #JSON ATTRS

    scope :with_mappings, -> { includes(:term_mappings, :name_roles, :desc_host_collections) }

    #Identifier
    attr_json :identifier, Curator::Descriptives::Identifier.to_type, container_attribute: :identifier_json, array: true, default: []

    ##Title
    attr_json :title, Curator::Descriptives::TitleSet.to_type, container_attribute: :title_json

    #Notes
    attr_json :note, Curator::Descriptives::Note.to_type, container_attribute: :note_json, array: true, default: []

    #Date
    attr_json :date, Curator::Descriptives::Date.to_type, container_attribute: :date_json

    #Publication
    attr_json :publication, Curator::Descriptives::Publication.to_type, container_attribute: :publication_json

    #Related
    attr_json :related, Curator::Descriptives::Related.to_type, container_attribute: :related_json

    #Cartographics
    attr_json :cartographic, Curator::Descriptives::Cartographic.to_type, container_attribute: :cartographics_json

    #Non REL Subjects
    attr_json :subject_other, Curator::Descriptives::Subject.to_type, container_attribute: :subject_json

    #RELS
    #PARENTS
    belongs_to :descriptable, polymorphic: true, inverse_of: :descriptive
    belongs_to :physical_location, inverse_of: :physical_locations_of, class_name: Curator.controlled_terms.name_class_name

    #MAPPING OBJECTS
    has_many :desc_terms, -> { joins(:mappable).preload(:mappable) }, inverse_of: :descriptive, class_name: Curator.mappings.desc_term_class_name
    has_many :name_roles,  -> { includes(:name, :role) }, inverse_of: :descriptive, class_name: Curator.mappings.desc_name_role_class_name
    has_many :desc_host_collections, -> { includes(:host_collection) }, inverse_of: :descriptive, class_name: Curator.mappings.desc_host_collection_class_name
    has_many :host_collections, through: :desc_host_collections, source: :host_collection

    #TERMS
    with_options through: :desc_terms, source: :mappable do
      has_many :genres, -> { merge(with_authority) }, source_type: Curator.controlled_terms.genre_class_name
      has_many :resource_types, -> { merge(with_authority) }, source_type: Curator.controlled_terms.resource_type_class_name
      has_many :licenses, source_type: Curator.controlled_terms.license_class_name
      has_many :languages, -> { merge(with_authority) }, source_type: Curator.controlled_terms.language_class_name
      has_many :subject_topics, -> { merge(with_authority) }, source_type: Curator.controlled_terms.subject_class_name
      has_many :subject_names, -> { merge(with_authority) }, source_type: Curator.controlled_terms.name_class_name
      has_many :subject_geos, -> { merge(with_authority) }, source_type: Curator.controlled_terms.geographic_class_name
    end
  end
end
