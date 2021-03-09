# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/jobs_shared'
RSpec.describe Curator::Indexer::IndexingJob, type: :job do
  describe 'expected job behavior' do
    subject { described_class }

    let(:job_args) { create(:curator_institution) }
    let(:expected_queue) { 'indexing' }

    before(:each) do
      ActiveJob::Base.queue_adapter = :test
    end

    it_behaves_like 'queueable'

    it 'sends an update request to the indexing service' do
      ActiveJob::Base.queue_adapter.perform_enqueued_jobs = true
      timestamp = Time.current
      subject.perform_later(job_args)
      # don't use assert_requested here, too hard to match body, check solr timestamp instead
      rsolr = RSolr.connect url: Curator.config.solr_url
      solr_resp = rsolr.get 'select', params: { q: "id:\"#{job_args.ark_id}\"" }
      solr_rec = solr_resp['response']['docs'].first
      expect(solr_rec['timestamp']).to be > timestamp
    end
  end
end
