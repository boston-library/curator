# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/json_serialization'

RSpec.describe Curator::Metastreams::DescriptiveSerializer, type: :serializers do
  let!(:desc_term_count) { 2 }
  let!(:record) { create(:curator_metastreams_descriptive, :with_all_desc_terms, desc_term_count: desc_term_count) }

  describe 'Serialization' do
    it_behaves_like 'json_serialization', include_collections: false do
      let(:json_record) { record }
      let(:json_array) { [] }

      let(:expected_json_serializer_class) do
        serializer_test_class(&descriptive_json_block)
      end

      let(:expected_json) do
        lambda do |descriptive|
          expected_json_serializer_class.new(descriptive).serialize(root_key: :descriptive)
        end
      end
    end
  end
end
