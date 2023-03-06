# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/inherited_serializers'
require_relative '../shared/json_serialization'

RSpec.describe Curator::Filestreams::TextSerializer, type: :serializers do
  let!(:text_file_set_count) { 2 }
  let!(:record_collection) { create_list(:curator_filestreams_text, text_file_set_count) }
  let!(:record) { create(:curator_filestreams_text) }

  describe 'Base Behavior' do
    it_behaves_like 'file_set_serializer'
  end

  describe 'Serialization' do
    it_behaves_like 'json_serialization' do
      let(:json_record) { record }
      let(:json_array) { record_collection }

      let(:expected_json_serializer_class) do
        serializer_test_class do
          root_key :file_set, :file_sets

          attributes :ark_id, :created_at, :updated_at, :file_name_base, :position

          attribute :file_set_type do |resource|
            resource.file_set_type.demodulize.downcase
          end

          one :pagination do
            attributes :page_label, :page_type, :hand_side
          end

          has_one :file_set_of do
            attributes :ark_id
          end

          has_many :file_set_members_of do
            attributes :ark_id
          end

          nested :metastreams do
            has_one :administrative do
              attributes :description_standard, :harvestable, :flagged, :destination_site, :hosting_status
            end

            has_one :workflow do
              attributes :publishing_state, :processing_state, :ingest_origin
            end
          end
        end
      end

      let(:expected_json) do
        lambda do |file_set|
          expected_json_serializer_class.new(file_set).serialize
        end
      end
    end
  end
end
