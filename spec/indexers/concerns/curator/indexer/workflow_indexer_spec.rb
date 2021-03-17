# frozen_string_literal: true

require 'rails_helper'
RSpec.describe Curator::Indexer::WorkflowIndexer do
  describe 'indexing' do
    let(:indexer_test_class) do
      Class.new(Curator::Indexer) do
        include Curator::Indexer::WorkflowIndexer
      end
    end
    let(:indexer) { indexer_test_class.new }
    let(:workflowable_object) { create(:curator_institution) }
    let(:indexed) { indexer.map_record(workflowable_object) }
    let(:workflow) { workflowable_object.workflow }

    it 'sets the publishing_state field' do
      expect(indexed['publishing_state_ssi']).to eq [workflow.publishing_state]
    end

    it 'sets the processing_state field' do
      expect(indexed['processing_state_ssi']).to eq workflow.processing_state
    end
  end
end
