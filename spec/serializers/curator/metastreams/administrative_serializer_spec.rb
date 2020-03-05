# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/json_serialization'

RSpec.describe Curator::Metastreams::AdministrativeSerializer, type: :serializers do
  let!(:administrative_count) { 3 }
  let!(:record_collection) { create_list(:curator_metastreams_administrative, administrative_count) }
  let!(:record) { record_collection.last }

  describe 'Serialization' do
    it_behaves_like 'json_serialization' do
      let!(:json_record) { record }
      let!(:json_array) { record_collection }
      let!(:expected_as_json_options) do
        {
          root: true,
          only: [:description_standard, :flagged, :harvestable, :destination_site]
        }
      end
    end
  end
end
