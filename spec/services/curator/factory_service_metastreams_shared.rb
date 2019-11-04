# frozen_string_literal: true

RSpec.shared_examples 'workflowable' do |object_json|
  describe 'workflow metastream' do
    let(:workflow) { subject.workflow }
    let(:workflow_json) { object_json['metastreams']['workflow'] }

    it 'creates the workflow object' do
      expect(workflow).to be_an_instance_of(Curator::Metastreams::Workflow)
    end

    it 'sets the correct workflow metadata' do
      expect(workflow.processing_state).to eq workflow_json['processing_state']
      expect(workflow.publishing_state).to eq workflow_json['publishing_state']
      expect(workflow.ingest_origin).to eq workflow_json['ingest_origin']
    end
  end
end

RSpec.shared_examples 'administratable' do |object_json|
  describe 'administrative metastream' do
    let(:administrative) { subject.administrative }
    let(:administrative_json) { object_json['metastreams']['administrative'] }

    it 'creates the administrative object' do
      expect(administrative).to be_an_instance_of(Curator::Metastreams::Administrative)
    end

    it 'sets the correct administrative metadata' do
      expect(administrative.harvestable).to eq true
      expect(administrative.destination_site).to eq administrative_json['destination_site']
    end
  end
end
