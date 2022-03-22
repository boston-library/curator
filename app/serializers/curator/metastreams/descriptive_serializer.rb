# frozen_string_literal: true

module Curator
  class Metastreams::DescriptiveSerializer < Curator::Serializers::AbstractSerializer
    build_schema_as_json do
      root_key :descriptive, :descriptives

      attributes :abstract, :digital_origin, :origin_event, :text_direction, :resource_type_manuscript, :place_of_publication, :publisher, :issuance, :frequency, :extent, :physical_location_department, :physical_location_shelf_locator, :series, :subseries, :subsubseries, :rights, :access_restrictions, :toc, :toc_url, :title, :note, :cartographic, :date, :related, :publication

      attribute(:host_collections) { |record| record.host_collections.names }

      belongs_to :physical_location, serializer: Curator::ControlledTerms::NameSerializer
      belongs_to :license, serializer: Curator::ControlledTerms::LicenseSerializer
      belongs_to :rights_statement, serializer: Curator::ControlledTerms::RightsStatementSerializer

      has_many :resource_types, serializer: Curator::ControlledTerms::ResourceTypeSerializer
      has_many :genres, serializer: Curator::ControlledTerms::GenreSerializer
      has_many :languages, serializer: Curator::ControlledTerms::LanguageSerializer

      node :identifier, target: :key do
        attributes :label, :type, :invalid
      end

      node :note, target: :key do
        attributes :label, :type
      end

      node :title, target: :key do
        node :primary, target: :key do
          attributes :label, :subtitle, :display, :display_label, :usage, :supplied, :language, :type, :authority_code, :id_from_auth, :part_name, :part_number
        end

        node :other, target: :key do
          attributes :label, :subtitle, :display, :display_label, :usage, :supplied, :language, :type, :authority_code, :id_from_auth, :part_name, :part_number
        end
      end

      node :cartographic, target: :key do
        attributes :scale, :projection
      end

      node :date, target: :key do
        attributes :created, :issued, :copyright
      end

      node :related, target: :key do
        attributes :constituent, :other_format, :references_url, :review_url

        node :referenced_by, target: :key do
          attributes :label, :url
        end
      end

      node :publication, target: :key do
        attributes :edition_name, :edition_number, :volume, :issue_number
      end

      node :name_roles, target: :key do
        belongs_to :name, serializer: Curator::ControlledTerms::NameSerializer
        belongs_to :role, serializer: Curator::ControlledTerms::RoleSerializer
      end

      node :subject, target: :key do
        attributes :dates, :temporals

        has_many :topics, serializer: Curator::ControlledTerms::SubjectSerializer
        has_many :names, serializer: Curator::ControlledTerms::NameSerializer
        has_many :geos, serializer: Curator::ControlledTerms::GeographicSerializer

        node :titles, target: :key do
          attributes :label, :subtitle, :display, :display_label, :usage, :supplied, :language, :type, :authority_code, :id_from_auth, :part_name, :part_number
        end
      end
    end
  end
end
