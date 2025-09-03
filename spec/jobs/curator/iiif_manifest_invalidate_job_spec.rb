# frozen_string_literal: true

require 'rails_helper'
require_relative './shared/jobs_shared'

RSpec.describe Curator::IIIFManifestInvalidateJob, type: :job do
  describe 'expected job behavior' do
    subject { described_class }

    let(:ark_id) { 'bpl-dev:987654321' }
    let(:job_args) { [ark_id] }
    let(:expected_queue) { 'default' }

    it_behaves_like 'queueable'

    describe '#perform_later' do
      let(:iiif_manifest_invalidate_url) { "#{Curator.config.iiif_manifest_url}/search/#{ark_id}/manifest/cache_invalidate" }

      around(:each) do |spec|
        ActiveJob::Base.queue_adapter.perform_enqueued_at_jobs = true
        ActiveJob::Base.queue_adapter.perform_enqueued_jobs = true
        VCR.use_cassette('jobs/iiif_manifest_invalidate') do
          spec.run
        end
        ActiveJob::Base.queue_adapter.perform_enqueued_at_jobs = false
        ActiveJob::Base.queue_adapter.perform_enqueued_jobs = false
      end

      it 'sends a request to the invalidate the iiif manifest' do
        subject.perform_later(*job_args)
        expect(a_request(:post, iiif_manifest_invalidate_url)).to have_been_made.at_least_once
      end
    end
  end
end
