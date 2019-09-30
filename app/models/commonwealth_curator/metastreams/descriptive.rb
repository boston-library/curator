# frozen_string_literal: true
module CommonwealthCurator
  class Metastreams::Descriptive < ApplicationRecord
    include AttrJson::Record
    include AttrJson::Record::QueryScopes
    include AttrJson::Record::Dirty
    include AttrJson::NestedAttributes

    enum digital_origin: ['born digital', 'reformatted digital', 'digitized microfilm', 'digitized other analog'].freeze
    enum origin_event: %w(production publication distribution manufacture).freeze
    #JSON ATTRS

    default_scope { includes(:term_mappings, :name_roles, :desc_host_collections) }

    #Identifier
    attr_json :identifier, CommonwealthCurator::Descriptives::Identifier.to_type, container_attribute: :identifier_json, array: true, default: []

    ##Title
    attr_json :title, CommonwealthCurator::Descriptives::TitleSet.to_type, container_attribute: :title_json

    #Notes
    attr_json :note, CommonwealthCurator::Descriptives::Note.to_type, container_attribute: :note_json, array: true, default: []

    #Date
    attr_json :date, CommonwealthCurator::Descriptives::Date.to_type, container_attribute: :date_json

    #Related
    attr_json :related, CommonwealthCurator::Descriptives::Related.to_type, container_attribute: :related_json

    #Cartographics
    attr_json :cartographic, CommonwealthCurator::Descriptives::Cartographic.to_type, container_attribute: :cartographics_json

    #Non REL Subjects
    attr_json :subject_other, CommonwealthCurator::Descriptives::Subject.to_type, container_attribute: :subject_json

    #RELS
    #PARENTS
    belongs_to :descriptable, polymorphic: true, inverse_of: :descriptive
    belongs_to :physical_location, inverse_of: :is_physical_location_of, class_name: CommonwealthCurator.controlled_terms.name_class.to_s

    #MAPPING OBJECTS
    has_many :term_mappings, inverse_of: :descriptive, ->{ joins(:mappable).preload(:mappable) } ,class_name: 'CommonwealthCurator::Metastreams::DescriptiveTermMapping'
    #POLYMORPHIC MAP OBJECT
    has_many :name_roles, inverse_of: :descriptive, ->{ includes(:name, :role) }, class_name: 'CommonwealthCurator::Mappings::DescNameRoleMapping'
    has_many :desc_host_collections, inverse_of: :descriptive, -> { includes(:host_collection) } class_name: 'CommonwealthCurator::Mappings::DescHostCollection'

    #TERMS
    has_many :genres, through: :term_mappings, source: :mappable, source_type: 'CommonwealthCurator::ControlledTerms::Genre'
    has_many :resource_types, through: :term_mappings, source: :mappable, source_type: 'CommonwealthCurator::ControlledTerms::ResourceType'
    has_many :licenses, through: :term_mappings, source: :mappable, source_type: 'CommonwealthCurator::ControlledTerms::License'
    has_many :languages, through: :term_mappings, source: :mappable, source_type: 'CommonwealthCurator::ControlledTerms::Language'
    #SUBJECTS TERMS
    has_many :subject_topics, through: :term_mappings, source: :mappable, source_type: 'CommonwealthCurator::ControlledTerms::Subject'
    has_many :subject_names, through: :term_mappings, source: :mappable, source_type: 'CommonwealthCurator::ControlledTerms::Name'
    has_many :subject_geos, through: :term_mappings, source: :mappable, source_type: 'CommonwealthCurator::ControlledTerms::Geographic'

    #HOST COLLECTIONS
    has_many :host_collections, through: :desc_host_collections, source: :host_collection
  end
end
