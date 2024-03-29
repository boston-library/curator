# frozen_string_literal: true

require 'rails_helper'
require_relative './shared/factory_service_metastreams_shared'

RSpec.describe Curator::CollectionFactoryService, type: :service do
  before(:all) do
    # create parent Institution
    @object_json = load_json_fixture('collection')
    parent = create(:curator_institution)
    @object_json['institution']['ark_id'] = parent.ark_id
    expect do
      @success, @collection = handle_factory_result(described_class, @object_json)
    end.to change(Curator::Collection, :count).by(1)
  end

  specify { expect(@success).to be_truthy }
  specify { expect(@collection).to be_valid }

  describe '#call' do
    subject { @collection }

    it 'has the correct properties' do
      expect(subject.name).to eq @object_json['name']
      expect(subject.abstract).to eq @object_json['abstract']
      expect(subject.created_at).to eq Time.zone.parse(@object_json['created_at'])
    end

    describe 'setting institution' do
      let(:institution) { subject.institution }

      it 'creates the institution relationship' do
        expect(institution).to be_an_instance_of(Curator::Institution)
      end
    end

    it_behaves_like 'factory_workflowable'
    it_behaves_like 'factory_administratable'
  end
end
