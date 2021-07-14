# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/jobs_shared'
RSpec.describe Curator::Indexer::IndexingJob, type: :job do
  describe 'expected job behavior' do
    subject { described_class }

    let(:job_args) { create(:curator_institution) }
    let(:expected_queue) { 'indexing' }

    it_behaves_like 'queueable'

    describe '#perform_later' do
      let!(:solr_client) { RSolr.connect(url: Curator.config.solr_url) }

      around(:each) do |spec|
        ActiveJob::Base.queue_adapter = :test
        ActiveJob::Base.queue_adapter.perform_enqueued_jobs = true
        spec.run
      end

      it 'sends an update request to the indexing service' do
        timestamp = Time.current
        subject.perform_later(job_args)

        # NOTE: don't use assert_requested here, too hard to match body, check solr timestamp instead

        solr_resp = solr_client.get 'select', params: { q: "id:\"#{job_args.ark_id}\"" }
        solr_rec = solr_resp.dig('response', 'docs')&.first
        expect(solr_rec).to be_a_kind_of(Hash).and have_key('timestamp')
        expect(solr_rec['timestamp']).to be > timestamp
      end
    end
  end
end
