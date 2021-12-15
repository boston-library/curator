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
    subject!(:file_set) do
      fs = nil
      json_data = file_set_json.dup
      json_data['files'] = files_json
      json_data['file_set_of']['ark_id'] = parent_obj.ark_id
      json_data['exemplary_image_of'] = []
      json_data['exemplary_image_of'][0] = { 'ark_id' => parent_obj.ark_id }
      json_data['exemplary_image_of'][1] = { 'ark_id' => parent_col.ark_id }
      VCR.use_cassette('services/filestreams/file_set_for_derivatives') do
        _, fs = handle_factory_result(Curator::Filestreams::FileSetFactoryService, json_data)
      end
      fs
    end

    subject!(:called_result) do
      res = nil
      VCR.use_cassette('services/filestreams/derivatives') do
        res = described_class.call(file_set.avi_file_class, avi_payload: file_set.avi_payload)
      end
      res
    end

    let!(:parent_col) { create(:curator_collection) }
    let!(:parent_obj) { create(:curator_digital_object, admin_set: parent_col) }
    let!(:file_set_json) { load_json_fixture('image_file_set_2', 'file_set') }
    let!(:files_json) { load_json_fixture('image_file_2', 'files') }

    it 'expects the result to be successful' do
      expect(called_result).to be_truthy
      expect(called_result).to be_a_kind_of(Hash).and have_key(file_set.avi_file_class)
    end
  end
end
