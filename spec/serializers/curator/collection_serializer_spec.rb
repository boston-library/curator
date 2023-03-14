# frozen_string_literal: true

require 'rails_helper'
require_relative './shared/inherited_serializers'
require_relative './shared/json_serialization'

RSpec.describe Curator::CollectionSerializer, type: :serializers do
  let!(:collection_count) { 2 }

  let!(:record_collection) { create_list(:curator_collection, collection_count) }
  let!(:record) { record_collection.last }

  describe 'Base Behavior' do
    it_behaves_like 'curator_serializer'
  end

  describe 'Serialization' do
    it_behaves_like 'json_serialization' do
      let(:json_record) { record }
      let(:json_array) { record_collection }

      let(:expected_json_serializer_class) do
        serializer_test_class do
          root_key :collection, :collections

          attributes :ark_id, :abstract, :name

          attribute :created_at do |resource|
            format_time_iso8601(resource.created_at)
          end

          attribute :updated_at do |resource|
            format_time_iso8601(resource.updated_at)
          end

          has_one :institution do
            attributes :ark_id
          end

          nested :metastreams do
            has_one :administrative do
              attributes :description_standard, :harvestable, :flagged, :destination_site, :hosting_status
            end

            has_one :workflow do
              attributes :publishing_state, :processing_state, :ingest_origin
            end
          end
        end
      end

      let(:expected_json) do
        lambda do |collection|
          expected_json_serializer_class.new(collection).serialize
        end
      end
    end
  end
end
