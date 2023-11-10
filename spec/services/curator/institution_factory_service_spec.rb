# frozen_string_literal: true

require 'rails_helper'
require_relative './shared/factory_service_metastreams_shared'
require_relative './shared/attachable'

RSpec.describe Curator::InstitutionFactoryService, type: :service do
  before(:all) do
    @object_json = load_json_fixture('institution_with_thumbnail', 'institution')
    @object_json['files'][0]['io'] = { uploaded_file: Rack::Test::UploadedFile.new(file_fixture('image_thumbnail_300_institution.png').to_s, 'image/png') }
    VCR.use_cassette('services/institution_factory_service') do
      expect do
        @success, @institution = handle_factory_result(described_class, @object_json)
      end.to change(Curator::Institution, :count).by(1)
    end
  end

  specify { expect(@success).to be_truthy }
  specify { expect(@institution).to be_valid }

  describe '#call' do
    subject { @institution }

    it 'has the correct properties' do
      expect(subject.name).to eq @object_json['name']
      expect(subject.abstract).not_to be_blank
      expect(subject.url).to eq @object_json['url']
      expect(subject.created_at).to eq Time.zone.parse(@object_json['created_at'])
    end

    describe 'setting location data' do
      let(:location) { subject.location }

      it 'creates the associated location' do
        expect(location).to be_an_instance_of(Curator::ControlledTerms::Geographic)
      end

      it 'sets the correct location properties' do
        expect(location.label).to eq @object_json['location']['label']
        expect(location.id_from_auth).to eq @object_json['location']['id_from_auth']
      end
    end

    it_behaves_like 'factory_workflowable'
    it_behaves_like 'factory_administratable'
    it_behaves_like 'attachable' do
      let(:record) { @institution }
      let(:file_json) { @object_json.fetch('files', []).first }
    end
  end
end
