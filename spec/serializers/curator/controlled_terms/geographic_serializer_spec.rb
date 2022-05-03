# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/inherited_serializers'
require_relative '../shared/json_serialization'

RSpec.describe Curator::ControlledTerms::GeographicSerializer, type: :serializers do
  let!(:geographic_count) { 3 }
  let!(:record) { create(:curator_controlled_terms_geographic) }
  let!(:record_collection) { create_list(:curator_controlled_terms_geographic, geographic_count) }

  describe 'Base Behavior' do
    it_behaves_like 'nomenclature_serializer'
  end

  describe 'Serialization' do
    it_behaves_like 'json_serialization' do
      let(:json_record) { record }
      let(:json_array) { record_collection }

      let(:expected_json_serializer_class) do
        serializer_test_class do
          root_key :geographic, :geographics

          attributes :label, :id_from_auth, :authority_code, :bounding_box, :area_type, :coordinates
        end
      end

      let(:expected_json) do
        lambda do |geographic|
          expected_json_serializer_class.new(geographic).serialize
        end
      end
    end
  end
end
