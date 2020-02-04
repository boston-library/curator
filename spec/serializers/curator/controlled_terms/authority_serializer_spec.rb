# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/json_serialization'

RSpec.describe Curator::ControlledTerms::AuthoritySerializer, type: :serializers do
  let!(:authority_count) { 3 }
  let!(:record) { create(:curator_controlled_terms_authority) }
  let!(:record_collection) { create_list(:curator_controlled_terms_authority, authority_count) }

  describe 'Serialization' do
    it_behaves_like 'json_serialization' do
      let(:json_record) { record }
      let(:json_array) { record_collection }
      let(:expected_as_json_options) do
        {
          root: true,
          only: [:name, :code, :base_url]
        }
      end
    end
  end
end
