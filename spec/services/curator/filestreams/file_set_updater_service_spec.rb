# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/filestreams/attachable'

RSpec.describe Curator::Filestreams::FileSetUpdaterService, type: :service do
  before(:all) do
    @collection ||= create(:curator_collection)
    @digital_object ||= create(:curator_digital_object, admin_set: @collection)
    @file_set ||= create(:curator_filestreams_image, file_set_of: @digital_object)
    @files_json ||= load_json_fixture('image_file', 'files')

    @files_json[0]['metadata']['ingest_filepath'] = file_fixture('image_thumbnail_300.jpg').to_s

    create(:curator_mappings_exemplary_image, exemplary_object: @collection, exemplary_file_set: @file_set)

    @update_attributes ||= {
      position: 2,
      pagination: { page_label: '4', page_type: 'TOC', hand_side: 'left' },
      exemplary_image_of: [{ ark_id: @digital_object.ark_id }, { ark_id: @collection.ark_id, _destroy: '1' }],
      files: @files_json
    }

    VCR.use_cassette('services/filestreams/file_set/update') do
      @success, @result = described_class.call(@file_set, json_data: @update_attributes)
    end
  end

  describe '#call' do
    specify { expect(@success).to be_truthy }

    describe ':result' do
      subject { @result }

      specify { expect(subject).to be_valid }
      specify { expect(subject.ark_id).to eq(@file_set.ark_id) }

      it 'expects #position to have been updated' do
        expect(subject.position).to eq(@update_attributes[:position])
      end

      it 'expects :pagination atrributes to have been updated' do
        @update_attributes[:pagination].keys.each do |pagination_attr|
          expect(subject.public_send(pagination_attr)).to eq(@update_attributes[:pagination][pagination_attr])
        end
      end

      it 'expects the #exemplary_image_of_mappings to have been updated' do
        expect(subject.exemplary_image_of_mappings.count).to eq(1)
        expect(subject.exemplary_image_of.pluck('ark_id')).to include(@digital_object.ark_id)
        expect(subject.exemplary_image_of.pluck('ark_id')).not_to include(@collection.ark_id)
      end
    end
  end
end
