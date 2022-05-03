# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/inherited_serializers'
require_relative '../shared/json_serialization'

RSpec.describe Curator::ControlledTerms::GenreSerializer, type: :serializers do
  let!(:genre_count) { 3 }
  let!(:record) { create(:curator_controlled_terms_genre) }
  let!(:record_collection) { create_list(:curator_controlled_terms_genre, genre_count) }

  describe 'Base Behavior' do
    it_behaves_like 'nomenclature_serializer'
  end

  describe 'Serialization' do
    it_behaves_like 'json_serialization' do
      let(:json_record) { record }
      let(:json_array) { record_collection }

      let(:expected_json_serializer_class) do
        serializer_test_class do
          root_key :genre, :genres

          attributes :label, :id_from_auth, :authority_code, :basic
        end
      end

      let(:expected_json) do
        lambda do |genre|
          expected_json_serializer_class.new(genre).serialize
        end
      end
    end
  end
end
