# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/json_serialization'

RSpec.describe Curator::Metastreams::AdministrativeSerializer, type: :serializers do
  let!(:record) { create(:curator_metastreams_administrative, :for_oai_object) }

  describe 'Serialization' do
    it_behaves_like 'json_serialization', include_collections: false do
      let(:json_record) { record }
      let(:json_array) { [] }
      let(:expected_json_serializer_class) do
        serializer_test_class do
          root_key :administrative

          attributes :description_standard, :harvestable, :destination_site, :oai_header_id, :hosting_status, :flagged
        end
      end
      let(:expected_json) do
        lambda do |administrative|
          expected_json_serializer_class.new(administrative).serialize
        end
      end
    end
  end
end
