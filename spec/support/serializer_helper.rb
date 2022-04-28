# frozen_string_literal: true

module SerializerHelper
  module AsJsonHelper
    # NOTE: This method return the long list of options used for when #as_json on a descriptive is called of the descriptive as json
    # This is only required when stubbing out an expected value for as json in the descriptive class
    BLOB_KEY_TRANSFORMS = {
      'filename' => 'file_name',
      'content_type' => 'mime_type'
    }.freeze

    def normalize_blob_json(blob_json = {})
      blob_json['id'] = blob_json.delete('key')
      blob_json['metadata'] ||= {}

      %w(byte_size checksum filename content_type).each do |blob_field|
        next if !blob_json.key?(blob_field)

        if BLOB_KEY_TRANSFORMS.key?(blob_field)
          metadata_field = BLOB_KEY_TRANSFORMS[blob_field]
        else
          metadata_field = blob_field
        end
        blob_json['metadata'][metadata_field] = blob_json.delete(blob_field)
      end
      blob_json
    end

    def descriptive_json_block
      proc do
        attributes :abstract, :digital_origin, :origin_event, :text_direction, :resource_type_manuscript, :place_of_publication, :publisher, :issuance, :frequency, :extent, :physical_location_department, :physical_location_shelf_locator, :series, :subseries, :subsubseries, :rights, :access_restrictions, :toc, :toc_url, :title, :note, :cartographic, :date, :related, :publication

        attribute :host_collections do |descriptable|
          descriptable.host_collections.names
        end

        has_one :physical_location do
          attributes :label, :id_from_auth, :affiliation, :authority_code, :name_type
        end

        has_one :license do
          attributes :label, :id_from_auth, :uri
        end

        has_one :rights_statement do
          attributes :label, :id_from_auth, :uri
        end

        has_many :resource_types do
          attributes :label, :id_from_auth, :authority_code
        end

        has_many :genres do
          attributes :label, :id_from_auth, :basic, :authority_code
        end

        has_many :languages do
          attributes :label, :id_from_auth, :authority_code
        end

        many :identifier do
          attributes :label, :type, :invalid
        end

        many :note do
          attributes :label, :type
        end

        one :title do
          one :primary do
            attributes :label, :subtitle, :display, :display_label, :usage, :supplied, :language, :type, :authority_code, :id_from_auth, :part_name, :part_number
          end

          many :other do
            attributes :label, :subtitle, :display, :display_label, :usage, :supplied, :language, :type, :authority_code, :id_from_auth, :part_name, :part_number
          end
        end

        one :cartographic do
          attributes :scale, :projection
        end

        one :date do
          attributes :created, :issued, :copyright
        end

        one :related do
          attributes :constituent, :other_format, :references_url, :review_url

          many :referenced_by do
            attributes :label, :url
          end
        end

        one :publication do
          attributes :edition_name, :edition_number, :volume, :issue_number
        end

        has_many :name_roles do
          has_one :name do
            attributes :label, :id_from_auth, :affiliation, :authority_code, :name_type
          end

          has_one :role do
            attributes :label, :id_from_auth, :authority_code
          end
        end

        one :subject do
          attributes :dates, :temporals

          has_many :topics do
            attributes :label, :id_from_auth, :authority_code
          end

          has_many :names do
            attributes :label, :id_from_auth, :affiliation, :authority_code, :name_type
          end

          has_many :geos do
            attributes :label, :id_from_auth, :area_type, :coordinates, :bounding_box, :authority_code
          end

          many :titles do
            attributes :label, :subtitle, :display, :display_label, :usage, :supplied, :language, :type, :authority_code, :id_from_auth, :part_name, :part_number
          end
        end
      end
    end
  end

  module SchemaBuilderHelper
    def schema_attribute_keys(schema_builder_class = nil)
      return [] if schema_builder_class.blank?

      schema_builder_class._attributes.keys
    end
  end


  module IntegrationHelper
    include SchemaBuilderHelper
    include AsJsonHelper

    def serializer_adapter_schema_attributes(serializer_class, adapter_key, facet_group_key)
      return [] if adapter_key == :null

      serializer_class.send(:_schema_builder_for_adapter, adapter_key)&.schema_builder_class&._attributes || []
    end
  end
end

RSpec.configure do |config|
  config.include SerializerHelper::SchemaBuilderHelper, type: :lib_serializers
  config.include SerializerHelper::IntegrationHelper, type: :serializers
end
