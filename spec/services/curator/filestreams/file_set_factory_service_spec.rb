require 'rails_helper'
require_relative './../factory_service_metastreams_shared'
RSpec.describe Curator::Filestreams::FileSetFactoryService do
  json_fixture = File.join(Curator::Engine.root.join('spec', 'fixtures', 'files', 'file_set.json'))
  object_json = JSON.parse(File.read(json_fixture)).fetch('file_set', {})

  before(:all) do
    # create parent DigitalObject and Collection
    parent_col = create(:curator_collection)
    parent_obj = create(:curator_digital_object)
    parent_obj.workflow = create(:curator_metastreams_workflow)
    object_json['file_set_of']['ark_id'] = parent_obj.ark_id
    object_json['exemplary_image_of'][0]['ark_id'] = parent_obj.ark_id
    object_json['exemplary_image_of'][1]['ark_id'] = parent_col.ark_id
    object_json['metastreams']['workflow']['publishing_state'] = parent_obj.workflow.publishing_state
    expect do
      @file_set = described_class.call(json_data: object_json)
    end.to change { Curator::Filestreams::FileSet.count }.by(1)
  end

  describe '#call' do
    subject { @file_set }
    let(:file_set_type) { object_json['file_set_type'] }

    it 'has the correct properties' do
      %w(ark_id position file_name_base pagination).each do |attr|
        expect(@file_set.send(attr)).to eq object_json[attr]
      end
      expect(subject.file_set_type).to eq Curator.filestreams.send("#{file_set_type}_class_name")
      expect(subject.updated_at).to eq Time.zone.parse(object_json['updated_at'])
    end

    describe 'object relationships' do
      describe 'file_set_of' do
        let(:digital_object) { @file_set.file_set_of }
        it 'should set the file_set_of relationship' do
          expect(digital_object).to be_an_instance_of(Curator::DigitalObject)
          expect(digital_object.ark_id).to eq object_json['file_set_of']['ark_id']
        end
      end

      describe 'exemplary_image_of' do
        let(:exemplary_image_object) { @file_set.exemplary_image_objects.first }
        it 'should set the exemplary_image_object relationship' do
          expect(exemplary_image_object).to be_an_instance_of(Curator::DigitalObject)
          expect(exemplary_image_object.ark_id).to eq object_json['exemplary_image_of'][0]['ark_id']
        end

        let(:exemplary_image_collection) { @file_set.exemplary_image_collections.first }
        it 'should set the exemplary_image_collection relationship' do
          expect(exemplary_image_collection).to be_an_instance_of(Curator::Collection)
          expect(exemplary_image_collection.ark_id).to eq object_json['exemplary_image_of'][1]['ark_id']
        end
      end
    end

    it_behaves_like 'workflowable', object_json
  end
end
