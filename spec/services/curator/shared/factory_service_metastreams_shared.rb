# frozen_string_literal: true

RSpec.shared_examples 'factory_workflowable', type: :service do
  describe 'workflow metastream' do
    let(:workflow) { subject.workflow }
    let(:workflow_json) { @object_json['metastreams']['workflow'] }

    it 'creates the workflow object' do
      expect(workflow).to be_an_instance_of(Curator::Metastreams::Workflow)
    end

    it 'sets the correct workflow metadata' do
      expect(workflow.processing_state).to eq workflow_json.fetch('processing_state', nil)
      expect(workflow.publishing_state).to eq workflow_json.fetch('publishing_state', nil)
      expect(workflow.ingest_origin).to eq workflow_json['ingest_origin']
    end
  end
end

RSpec.shared_examples 'factory_administratable', type: :service do
  describe 'administrative metastream' do
    let(:administrative) { subject.administrative }
    let(:administrative_json) { @object_json['metastreams']['administrative'] }

    it 'creates the administrative object' do
      expect(administrative).to be_an_instance_of(Curator::Metastreams::Administrative)
    end

    it 'sets the correct administrative metadata' do
      expect(administrative.oai_header_id).to eq(administrative_json['oai_header_id'])
      expect(administrative.harvestable).to eq true
      expect(administrative.destination_site).to eq administrative_json['destination_site']
    end
  end
end
