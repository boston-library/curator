# frozen_string_literal: true

require 'rails_helper'
require_relative './factory_service_metastreams_shared'

RSpec.describe Curator::InstitutionFactoryService do
  before(:all) do
    @object_json = load_json_fixture('institution')
    expect do
      @institution = described_class.call(json_data: @object_json)
    end.to change { Curator::Institution.count }.by(1)
  end

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
