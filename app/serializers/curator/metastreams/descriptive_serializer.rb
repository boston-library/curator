# frozen_string_literal: true

module Curator
  class Metastreams::DescriptiveSerializer < CuratorSerializer
    CONTROLLED_TERMS_FIELDS = %i(label id_from_auth authority_code).freeze

    class DescriptiveNameRoleSerializer < ActiveModel::Serializer
      attribute :name do |serializer|
        serializer.name.as_json
      end

      attribute :role do |serializer|
        serializer.role.as_json
      end

      def name
        ActiveModelSerializers::SerializableResource.new(object.name, serializer: Curator::ControlledTerms::NameSerializer, adapter: :attributes, fields: CONTROLLED_TERMS_FIELDS + %i(type affiliation))
      end

      def role
        ActiveModelSerializers::SerializableResource.new(object.role, serializer: Curator::ControlledTerms::RoleSerializer, adapter: :attributes, fields: CONTROLLED_TERMS_FIELDS)
      end
    end

    attributes :abstract, :access_restrictions, :digital_origin, :edition, :frequency, :issuance, :origin_event, :physical_description_extent, :physical_location_department, :physical_location_shelf_locator, :place_of_publication, :publisher, :resource_type_manuscript, :rights, :series, :subseries, :toc, :toc_url, :name_role, :genre, :license, :language, :resource_type, :physical_location

    attribute :cartographic do
      object.cartographic.as_json
    end

    attribute :date do
      object.date.as_json
    end

    attribute :related do
      object.related.as_json
    end

    attribute :title do
      object.title.as_json
    end

    attribute :identifier do
      object.identifier.as_json
    end

    attribute :note do
      object.note.as_json
    end

    attribute :subject do |serializer|
      serializer.subject.as_json
    end

    # TODO Cache these methods #see https://github.com/rails-api/active_model_serializers/blob/0-10-stable/docs/general/serializers.md#associations
    def subject
      {}.merge(
        ActiveModelSerializers::SerializableResource.new(object.subject_topics, each_serializer: Curator::ControlledTerms::SubjectSerializer, root: 'topic', fields: CONTROLLED_TERMS_FIELDS).as_json
      ).merge(
        ActiveModelSerializers::SerializableResource.new(object.subject_names, each_serializer: Curator::ControlledTerms::NameSerializer, root: 'name', fields: CONTROLLED_TERMS_FIELDS + %i(affiliation type)).as_json
      ).merge(
        ActiveModelSerializers::SerializableResource.new(object.subject_geos, each_serializer: Curator::ControlledTerms::GeographicSerializer, root: 'geo', fields: CONTROLLED_TERMS_FIELDS + %i(coordinates bounding_box)).as_json
      ).merge(object.subject_other.as_json)
    end

    def name_role
      object.name_roles.map {|name_role| DescriptiveNameRoleSerializer.new(name_role).attributes }
    end

    def genre
      object.genres.map {|genre| Curator::ControlledTerms::GenreSerializer.new(genre).attributes(CONTROLLED_TERMS_FIELDS + %i(basic)) }
    end

    def language
      object.languages.map {|language| Curator::ControlledTerms::LanguageSerializer.new(language).attributes(CONTROLLED_TERMS_FIELDS) }
    end

    def resource_type
      object.resource_types.map {|resource_type| Curator::ControlledTerms::ResourceTypeSerializer.new(resource_type).attributes(CONTROLLED_TERMS_FIELDS) }
    end

    def license
      object.licenses.map {|license| Curator::ControlledTerms::LicenseSerializer.new(license).attributes(%i(label uri)) }
    end

    def physical_location
      Curator::ControlledTerms::NameSerializer.new(object.physical_location).attributes(CONTROLLED_TERMS_FIELDS + %i(affiliation type))
    end
  end
end
