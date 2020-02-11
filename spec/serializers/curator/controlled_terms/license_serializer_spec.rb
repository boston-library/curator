# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/inherited_serializers'
require_relative '../shared/json_serialization'

RSpec.describe Curator::ControlledTerms::LicenseSerializer, type: :serializers do
  let!(:license_count) { 3 }
  let!(:record) { create(:curator_controlled_terms_license) }
  let!(:record_collection) { create_list(:curator_controlled_terms_license, license_count) }

  describe 'Base Behavior' do
    it_behaves_like 'nomenclature_serializer', has_id_from_auth: false
  end

  describe 'Serialization' do
    it_behaves_like 'json_serialization' do
      let(:json_record) { record }
      let(:json_array) { record_collection }
      let(:expected_as_json_options) do
        {
          root: true,
          only: [:label, :uri],
          methods: [:label, :uri]
        }
      end
    end
  end
end
