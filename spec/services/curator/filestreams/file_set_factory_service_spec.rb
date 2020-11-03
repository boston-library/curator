# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/factory_service_metastreams_shared'
require_relative '../shared/filestreams/attachable'

RSpec.describe Curator::Filestreams::FileSetFactoryService, type: :service do
  before(:all) do
    @file_set_json = load_json_fixture('image_file_set', 'file_set')
    @files_json = load_json_fixture('image_file', 'files')
    # create parent DigitalObject and Collection
    parent_col = create(:curator_collection)
    parent_obj = create(:curator_digital_object)
    @file_set_json['file_set_of']['ark_id'] = parent_obj.ark_id
    @file_set_json['exemplary_image_of'][0]['ark_id'] = parent_obj.ark_id
    @file_set_json['exemplary_image_of'][1]['ark_id'] = parent_col.ark_id
    @file_set_json['metastreams']['workflow']['publishing_state'] = parent_obj.workflow.publishing_state
    @files_json[0]['metadata']['ingest_filepath'] = file_fixture('image_thumbnail_300.jpg').to_s
    @file_set_json['files'] = @files_json
    expect do
      @success, @file_set = handle_factory_result(described_class, @file_set_json)
    end.to change { Curator::Filestreams::FileSet.count }.by(1)
  end

  specify { expect(@success).to be_truthy }
  specify { expect(@file_set).to be_valid }

  describe '#call' do
    subject { @file_set.reload }

    let(:file_set_type) { @file_set_json['file_set_type'] }

    it_behaves_like 'attachable'

    it 'has the correct properties' do
      %w(ark_id position file_name_base pagination).each do |attr|
        expect(@file_set.send(attr)).to eq @file_set_json[attr]
      end
      expect(subject.file_set_type).to eq Curator.filestreams.send("#{file_set_type}_class").to_s
      expect(subject.created_at).to eq Time.zone.parse(@file_set_json['created_at'])
    end

    describe 'object relationships' do
      describe 'file_set_of' do
        let(:digital_object) { @file_set.file_set_of }
        it 'sets the file_set_of relationship' do
          expect(digital_object).to be_an_instance_of(Curator::DigitalObject)
          expect(digital_object.ark_id).to eq @file_set_json['file_set_of']['ark_id']
        end
      end

      describe 'exemplary_image_of' do
        let(:exemplary_image_object) { @file_set.exemplary_image_of_objects.first }
        it 'sets the exemplary_image_object relationship' do
          expect(exemplary_image_object).to be_an_instance_of(Curator::DigitalObject)
          expect(exemplary_image_object.ark_id).to eq @file_set_json['exemplary_image_of'][0]['ark_id']
        end

        let(:exemplary_image_collection) { @file_set.exemplary_image_of_collections.first }
        it 'sets the exemplary_image_collection relationship' do
          expect(exemplary_image_collection).to be_an_instance_of(Curator::Collection)
          expect(exemplary_image_collection.ark_id).to eq @file_set_json['exemplary_image_of'][1]['ark_id']
        end
      end
    end

    it_behaves_like 'factory_workflowable' do
      before(:each) do
        @object_json = @file_set_json
      end
    end
  end
end
