# frozen_string_literal: true

require 'rails_helper'
require_relative './shared/inherited_serializers'
require_relative './shared/json_serialization'

RSpec.describe Curator::DigitalObjectSerializer, type: :serializers do
  let!(:digital_object_count) { 2 }
  let!(:desc_term_count) { 2 }
  let!(:objs) { create_list(:curator_digital_object, digital_object_count, desc_term_count: desc_term_count) }
  let!(:record) { objs.last }

  let!(:record_collection) do
    Curator.digital_object_class.where(id: objs.pluck(:id)).for_serialization
  end

  describe 'Base Behavior' do
    it_behaves_like 'curator_serializer'
  end

  describe 'Serialization' do
    it_behaves_like 'json_serialization' do
      let(:json_record) { record }
      let(:json_array) { record_collection }
      let(:expected_json_serializer_class) do
        serializer_test_class do
          root_key :digital_object, :digital_objects

          attributes :ark_id

          attribute :created_at do |resource|
            format_time_iso8601(resource.created_at)
          end

          attribute :updated_at do |resource|
            format_time_iso8601(resource.updated_at)
          end

          has_one :admin_set do
            attributes :ark_id
          end

          has_one :contained_by do
            attributes :ark_id
          end

          has_many :is_member_of_collection do
            attributes :ark_id
          end

          nested :metastreams do
            has_one :administrative do
              attributes :description_standard, :harvestable, :flagged, :destination_site, :hosting_status
            end

            has_one :descriptive do
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

                many :preceding do
                  attributes :label, :control_number
                end

                many :succeeding do
                  attributes :label, :control_number
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

            has_one :workflow do
              attributes :publishing_state, :processing_state, :ingest_origin
            end
          end
        end
      end

      let(:expected_json) do
        lambda do |digital_object|
          expected_json_serializer_class.new(digital_object).serialize
        end
      end
    end
  end
end
