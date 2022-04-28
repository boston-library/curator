# frozen_string_literal: true

require 'rails_helper'
require_relative './shared/inherited_serializers'
require_relative './shared/json_serialization'

RSpec.describe Curator::CollectionSerializer, type: :serializers do
  let!(:collection_count) { 3 }

  let!(:record_collection) do
    cols = create_list(:curator_collection, collection_count)
    Curator.collection_class.where(id: cols.pluck(:id)).for_serialization
  end

  let!(:record) { record_collection.last }

  describe 'Base Behavior' do
    it_behaves_like 'curator_serializer'
  end

  describe 'Serialization' do
    it_behaves_like 'json_serialization' do
      let(:json_record) { record }
      let(:json_array) { record_collection }
      let(:expected_json) do
        proc do |resource|
          Alba.serialize(resource) do
            root_key :collection, :collections

            attributes :ark_id, :created_at, :updated_at, :abstract, :name

            has_one :institution do
              attributes :ark_id
            end

            has_one :metastreams do
              has_one :administrative do
                attributes :description_standard, :harvestable, :flagged, :destination_site, :hosting_status
              end

              has_one :workflow do
                attributes :publishing_state, :processing_state, :ingest_origin
              end
            end
          end
        end
      end
    end
  end
end
