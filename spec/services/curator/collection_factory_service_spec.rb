require 'rails_helper'
require_relative './factory_service_metastreams_shared'
RSpec.describe Curator::CollectionFactoryService do
  json_fixture = File.join(Curator::Engine.root.join('spec', 'fixtures', 'files', 'collection.json'))
  object_json = JSON.parse(File.read(json_fixture)).fetch('collection', {})

  before(:all) do
    # create parent Institution
    parent = create(:curator_institution)
    object_json['institution']['ark_id'] = parent.ark_id
    expect do
      @collection = described_class.call(json_data: object_json)
    end.to change { Curator::Collection.count }.by(1)
  end

  describe '#call' do
    subject { @collection }

    it 'has the correct properties' do
      expect(subject.name).to eq object_json['name']
      expect(subject.updated_at).to eq Time.zone.parse(object_json['updated_at'])
    end

    describe 'setting institution' do
      let(:institution) { subject.institution }

      it 'creates the institution relationship' do
        expect(institution).to be_an_instance_of(Curator::Institution)
      end
    end

    it_behaves_like 'workflowable', object_json
    it_behaves_like 'administratable', object_json
  end
end
