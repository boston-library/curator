# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/jobs_shared'

RSpec.describe Curator::Filestreams::IIIFCacheInvalidateJob, type: :job do
  describe 'expected job behavior' do
    subject { described_class }

    let(:job_args) { 'bpl-dev:987654321' }
    let(:expected_queue) { 'default' }

    it_behaves_like 'queueable'

    describe '#perform_later' do
      let(:iiif_server_url) { "#{Curator.config.iiif_server_url}/tasks" }
      let(:body) do
        {
          verb: 'PurgeItemFromCache',
          identifier: job_args
        }
      end

      around(:each) do |spec|
        ActiveJob::Base.queue_adapter.perform_enqueued_at_jobs = true
        ActiveJob::Base.queue_adapter.perform_enqueued_jobs = true
        VCR.use_cassette('jobs/filestreams/iiif_cache_invalidate') do
          spec.run
        end
        ActiveJob::Base.queue_adapter.perform_enqueued_at_jobs = false
        ActiveJob::Base.queue_adapter.perform_enqueued_jobs = false
      end

      it 'sends a request to invalidate the IIIF cache' do
        subject.perform_later(job_args)
        expect(a_request(:post, iiif_server_url).with(body: body)).to have_been_made.at_least_once
      end
    end
  end
end
