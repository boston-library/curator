# frozen_string_literal: true

require 'rails_helper'
require_relative './shared/factory_service_metastreams_shared'

RSpec.describe Curator::InstitutionFactoryService, type: :service do
  before(:all) do
    @object_json = load_json_fixture('institution')
    VCR.use_cassette('services/institution_factory_service', record: :new_episodes) do
      expect do
        @success, @institution = handle_factory_result(described_class, @object_json)
      end.to change { Curator::Institution.count }.by(1)
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
  end
end
