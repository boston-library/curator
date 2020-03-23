# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/inherited_serializers'
require_relative '../shared/json_serialization'

RSpec.describe Curator::Filestreams::ImageSerializer, type: :serializers do
  let!(:image_file_set_count) { 3 }
  let!(:record_collection) do
    images = create_list(:curator_filestreams_image, image_file_set_count)
    Curator.filestreams.image_class.where(id: images.pluck(:id)).for_serialization
  end

  let!(:record) { record_collection.last }

  describe 'Base Behavior' do
    it_behaves_like 'file_set_serializer'
  end

  describe 'Serialization' do
    it_behaves_like 'json_serialization' do
      let(:json_record) { record }
      let(:json_array) { record_collection }
      let(:expected_as_json_options) do
        {
          after_as_json: -> (json_record) { json_record['file_set_type'] = json_record['file_set_type'].to_s.demodulize.downcase if json_record.key?('file_set_type'); json_record },
          root: true,
          only: [:ark_id, :created_at, :updated_at, :file_name_base, :file_set_type, :position, :pagination],
          include: {
            file_set_of: {
              only: [:ark_id]
            }
          },
          administrative: {
            root: true,
            only: [:description_standard, :harvestable, :flagged, :destination_site]
          },
          workflow: {
            root: true,
            only: [:publishing_state, :processing_state, :ingest_origin]
          }
        }
      end
    end
  end
end
