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

      let(:expected_json_serializer_class) do
        serializer_test_class do
          root_key :authority, :authorities

          attributes :name, :code, :base_url
        end
      end

      let(:expected_json) do
        lambda do |authority|
          expected_json_serializer_class.new(authority).serialize
        end
      end
    end
  end
end
