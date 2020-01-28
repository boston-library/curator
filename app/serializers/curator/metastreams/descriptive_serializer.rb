# frozen_string_literal: true

module Curator
  class Metastreams::DescriptiveSerializer < Curator::Serializers::AbstractSerializer
    schema_as_json root: :descriptive do
      attributes :abstract, :digital_origin, :origin_event, :text_direction, :resource_type_manuscript, :place_of_publication, :publisher, :issuance, :frequency, :extent, :physical_location_department, :physical_location_shelf_locator, :series, :subseries, :subsubseries, :rights, :access_restrictions, :toc, :toc_url

      attribute(:host_collections) { |record| record.host_collections.pluck(:name) }

      belongs_to :physical_location, serializer: Curator::ControlledTerms::NameSerializer

      has_many :resource_types, serializer: Curator::ControlledTerms::ResourceTypeSerializer
      has_many :genres, serializer: Curator::ControlledTerms::GenreSerializer
      has_many :languages, serializer: Curator::ControlledTerms::LanguageSerializer
      has_many :licenses, serializer: Curator::ControlledTerms::LicenseSerializer

      node :identifier, target: :key do
        attributes :label, :type, :invalid
      end

      node :title, target: :key do
        node :primary, target: :key do
          attributes :label, :subtitle, :display, :display_label, :usage, :supplied, :language, :type, :authority_code, :id_from_auth, :part_name, :part_number
        end

        node :other, target: :key do
          attributes :label, :subtitle, :display, :display_label, :usage, :supplied, :language, :type, :authority_code, :id_from_auth, :part_name, :part_number
        end
      end

      node :note, target: :key do
        attributes :label, :type
      end

      node :cartographic, target: :key do
        attributes :scale, :projection
      end

      node :date, target: :key do
        attributes :created, :issued, :copyright
      end

      node :related, target: :key do
        attributes :constituent, :other_format, :referenced_by_url, :references_url, :review_url
      end

      node :publication, target: :key do
        attributes :edition_name, :edition_number, :volume, :issue_number
      end

      node :name_roles, target: :key do
        belongs_to :name, serializer: Curator::ControlledTerms::NameSerializer
        belongs_to :role, serializer: Curator::ControlledTerms::RoleSerializer
      end

      node :subject do
        has_many :topics, serializer: Curator::ControlledTerms::SubjectSerializer
        has_many :names, serializer: Curator::ControlledTerms::NameSerializer
        has_many :geos, serializer: Curator::ControlledTerms::GeographicSerializer

        node :titles, target: -> (record) { record.subject_other.titles }, if: -> (record, _) { record.subject_other.present? } do
          attributes :label, :subtitle, :display, :display_label, :usage, :supplied, :language, :type, :authority_code, :id_from_auth, :part_name, :part_number
        end
        attribute(:temporals, if: -> (record, _) { record.subject_other.present? }) { |record| record.subject_other.temporals }
        attribute(:dates, if: -> (record, _) { record.subject_other.present? }) { |record| record.subject_other.dates }
      end
    end
    # attribute :cartographic do
    #   object.cartographic.as_json
    # end
    #
    # attribute :date do
    #   object.date.as_json
    # end
    #
    # attribute :related do
    #   object.related.as_json
    # end
    #
    # attribute :title do
    #   object.title.as_json
    # end
    #
    # attribute :identifier do
    #   object.identifier.as_json
    # end
    #
    # attribute :note do
    #   object.note.as_json
    # end
    #
    # attribute :subject do |serializer|
    #   serializer.subject.as_json
    # end
    #
    # # TODO: Cache these methods #see https://github.com/rails-api/active_model_serializers/blob/0-10-stable/docs/general/serializers.md#associations
    # def subject
    #   {}.merge(
    #     ActiveModelSerializers::SerializableResource.new(object.subject_topics, each_serializer: Curator::ControlledTerms::SubjectSerializer, root: 'topic', fields: CONTROLLED_TERMS_FIELDS).as_json
    #   ).merge(
    #     ActiveModelSerializers::SerializableResource.new(object.subject_names, each_serializer: Curator::ControlledTerms::NameSerializer, root: 'name', fields: CONTROLLED_TERMS_FIELDS + %i(affiliation type)).as_json
    #   ).merge(
    #     ActiveModelSerializers::SerializableResource.new(object.subject_geos, each_serializer: Curator::ControlledTerms::GeographicSerializer, root: 'geo', fields: CONTROLLED_TERMS_FIELDS + %i(coordinates bounding_box)).as_json
    #   ).merge(object.subject_other.as_json)
    # end
    #
    # def name_role
    #   object.name_roles.map { |name_role| DescriptiveNameRoleSerializer.new(name_role).attributes }
    # end
    #
    # def genre
    #   object.genres.map { |genre| Curator::ControlledTerms::GenreSerializer.new(genre).attributes(CONTROLLED_TERMS_FIELDS + %i(basic)) }
    # end
    #
    # def language
    #   object.languages.map { |language| Curator::ControlledTerms::LanguageSerializer.new(language).attributes(CONTROLLED_TERMS_FIELDS) }
    # end
    #
    # def resource_type
    #   object.resource_types.map { |resource_type| Curator::ControlledTerms::ResourceTypeSerializer.new(resource_type).attributes(CONTROLLED_TERMS_FIELDS) }
    # end
    #
    # def license
    #   object.licenses.map { |license| Curator::ControlledTerms::LicenseSerializer.new(license).attributes(%i(label uri)) }
    # end
    #
    # def physical_location
    #   Curator::ControlledTerms::NameSerializer.new(object.physical_location).attributes(CONTROLLED_TERMS_FIELDS + %i(affiliation type))
    # end
  end
end
