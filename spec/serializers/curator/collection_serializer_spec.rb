# frozen_string_literal: true

require 'rails_helper'
require_relative './shared/inherited_serializers'
require_relative './shared/json_serialization'

RSpec.describe Curator::CollectionSerializer, type: :serializers do
  let!(:collection_count) { 3 }
  let!(:record) { create(:curator_collection, :with_metastreams) }
  let!(:record_collection) { create_list(:curator_collection, collection_count, :with_metastreams) }

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
          only: [:ark_id, :created_at, :updated_at, :abstract, :name],
          include: {
            institution: {
              only: [:ark_id]
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
