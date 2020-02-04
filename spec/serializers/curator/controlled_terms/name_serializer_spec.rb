# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/inherited_serializers'
require_relative '../shared/json_serialization'

RSpec.describe Curator::ControlledTerms::NameSerializer, type: :serializers do
  let!(:name_count) { 3 }
  let!(:record) { create(:curator_controlled_terms_name) }
  let!(:record_collection) { create_list(:curator_controlled_terms_name, name_count) }

  describe 'Base Behavior' do
    it_behaves_like 'nomenclature_serializer'
  end

  skip 'Serialization' do
    # TODO: Figure out a way to allow message for json_array
    it_behaves_like 'json_serialization' do
      let(:json_record) { record }
      let(:json_array) { record_collection }
      let(:expected_as_json_options) do
        {
          root: true,
          only: [:label, :id_from_auth, :authority_code, :affiliation, :type],
          methods: [:label, :id_from_auth, :authority_code, :bounding_box, :affiliation, :type]
        }

        before(:each) { allow(record).to recieve(:type) { record.name_type } }
      end
    end
  end
end
