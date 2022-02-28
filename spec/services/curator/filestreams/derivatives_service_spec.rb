# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/remote_service'

RSpec.describe Curator::Filestreams::DerivativesService, type: :service do
  subject { described_class }

  it_behaves_like 'remote_service'

  it 'expects the .base_url to eq the Curator.config.avi_processor_url' do
    expect(subject.base_url).to eq(Curator.config.avi_processor_api_url)
  end

  describe '#call' do
    let!(:parent_col) { create(:curator_collection) }
    let!(:parent_obj) { create(:curator_digital_object, admin_set: parent_col) }

    context 'image_file_set' do
      subject!(:image_file_set) do
        fs = nil
        json_data = image_file_set_json.dup
        json_data['files'] = image_files_json
        json_data['file_set_of']['ark_id'] = parent_obj.ark_id
        json_data['exemplary_image_of'] = []
        json_data['exemplary_image_of'][0] = { 'ark_id' => parent_obj.ark_id }
        json_data['exemplary_image_of'][1] = { 'ark_id' => parent_col.ark_id }
        VCR.use_cassette('services/filestreams/image_file_set_for_derivatives') do
          _, fs = handle_factory_result(Curator::Filestreams::FileSetFactoryService, json_data)
        end
        fs
      end

      subject!(:image_called_result) do
        res = nil
        VCR.use_cassette('services/filestreams/image_derivatives') do
          res = described_class.call(image_file_set.avi_file_class, avi_payload: image_file_set.avi_payload)
        end
        res
      end

      let!(:image_file_set_json) { load_json_fixture('image_file_set_2', 'file_set') }
      let!(:image_files_json) { load_json_fixture('image_file_2', 'files') }

      it 'expects the result to be successful' do
        expect(image_called_result).to be_truthy
        expect(image_called_result).to be_a_kind_of(Hash).and have_key(image_file_set.avi_file_class)
      end
    end

    context 'video_file_set' do
      subject!(:video_file_set) do
        fs = nil
        json_data = video_file_set_json.dup
        json_data['files'] = video_files_json
        json_data['file_set_of']['ark_id'] = parent_obj.ark_id
        VCR.use_cassette('services/filestreams/video_file_set_for_derivatives') do
          _, fs = handle_factory_result(Curator::Filestreams::FileSetFactoryService, json_data)
        end
        fs
      end

      subject!(:video_called_result) do
        res = nil
        VCR.use_cassette('services/filestreams/video_derivatives') do
          res = described_class.call(video_file_set.avi_file_class, avi_payload: video_file_set.avi_payload)
        end
        res
      end

      it 'expects the result to be successful' do
        expect(video_called_result).to be_truthy
        expect(video_called_result).to be_a_kind_of(Hash).and have_key(video_file_set.avi_file_class)
      end

      let!(:video_file_set_json) { load_json_fixture('video_file_set', 'file_set') }
      let!(:video_files_json) do
        files = []
        files += load_json_fixture('video_file', 'files')
        files += load_json_fixture('video_file_2', 'files')
        files
      end
    end
  end
end
