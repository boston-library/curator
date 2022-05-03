# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/json_serialization'

RSpec.describe Curator::Metastreams::WorkflowSerializer, type: :serializers do
  let!(:record) { create(:curator_metastreams_workflow) }

  describe 'Serialization' do
    it_behaves_like 'json_serialization', include_collections: false do
      let(:json_record) { record }
      let(:json_array) { [] }

      let(:expected_json_serializer_class) do
        serializer_test_class do
          root_key :workflow

          attributes :publishing_state, :processing_state, :ingest_origin
        end
      end

      let(:expected_json) do
        lambda do |workflow|
          expected_json_serializer_class.new(workflow).serialize
        end
      end
    end
  end
end
