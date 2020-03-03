# frozen_string_literal: true

require 'rails_helper'
require_relative './shared/inherited_serializers'
require_relative './shared/json_serialization'
RSpec.describe Curator::InstitutionSerializer, type: :serializers do
  let!(:institution_count) { 3 }
  let!(:record) { create(:curator_institution, :with_location) }
  let!(:record_collection) { create_list(:curator_institution, institution_count, :with_location) }

  describe 'Base Behavior' do
    it_behaves_like 'curator_serializer'
  end

  describe 'Serialization' do
    it_behaves_like 'json_serialization' do
      let(:json_record) { record }
      let(:json_array) { record_collection }
      let(:expected_as_json_options) do
        {
          root: true,
          only: [:ark_id, :created_at, :updated_at, :name, :abstract, :url],
          include: {
            location: {
              methods: [:area_type, :coordinates, :bounding_box, :authority_code, :label, :id_from_auth],
              only: [:area_type, :coordinates, :bounding_box, :authority_code, :label, :id_from_auth]
            }
          },
          administrative: {
            root: true,
            only: [:description_standard, :harvestable, :flagged, :destination_site]
          },
          workflow: {
            root: true,
            only: [:publishing_state, :processing_state, :ingest_origin]
          }
        }
      end
    end
  end
end
