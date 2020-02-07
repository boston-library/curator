# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/json_serialization'

RSpec.describe Curator::Metastreams::DescriptiveSerializer, type: :serializers do
  let!(:descriptive_count) { 3 }
  let!(:desc_term_counts) { 3 }
  let!(:record) { create(:curator_metastreams_descriptive, :with_all_desc_terms, desc_term_count: desc_term_counts) }
  let!(:record_collection) { create_list(:curator_metastreams_descriptive, descriptive_count, :with_all_desc_terms, desc_term_count: desc_term_counts) }

  describe 'Serialization' do
    it_behaves_like 'json_serialization' do
      let(:json_record) { record }
      let(:json_array) { record_collection }
      let(:expected_as_json_options) { descriptive_as_json_options }
    end
  end
end
