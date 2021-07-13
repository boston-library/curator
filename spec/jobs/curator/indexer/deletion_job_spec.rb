# frozen_string_literal: true

require 'rails_helper'
require_relative '../../../indexers/concerns/curator/shared/indexable_shared'
require_relative '../shared/jobs_shared'
RSpec.describe Curator::Indexer::DeletionJob, type: :job do
  include_context 'indexable_shared'

  describe 'expected job behavior' do
    subject { described_class }

    let(:job_args) { 'bpl-dev:987654321' }
    let(:expected_queue) { 'indexing' }

    it_behaves_like 'queueable'

    describe '#perform_later' do
      around(:each) do |spec|
        ActiveJob::Base.queue_adapter = :test
        ActiveJob::Base.queue_adapter.perform_enqueued_jobs = true
        spec.run
      end

      it 'sends a delete request to the indexing service' do
        subject.perform_later(job_args)
        expect(a_request(:post, solr_update_url).with(body: { 'delete' => job_args }.to_json)).to have_been_made.at_least_once
      end
    end
  end
end
