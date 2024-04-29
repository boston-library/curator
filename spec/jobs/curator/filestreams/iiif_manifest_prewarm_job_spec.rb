# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/jobs_shared'

RSpec.describe Curator::Filestreams::IIIFManifestPrewarmJob, type: :job do
  describe 'expected job behavior' do
    subject { described_class }

    let(:job_args) { 'bpl-dev:8049g5699' }
    let(:expected_queue) { 'iiif' }

    it_behaves_like 'queueable'

    describe '#perform_later' do
      let(:iiif_manifest_url) { "#{Curator.config.iiif_server_url}/iiif/2/#{job_args}/info.json" }

      around(:each) do |spec|
        ActiveJob::Base.queue_adapter.perform_enqueued_at_jobs = true
        ActiveJob::Base.queue_adapter.perform_enqueued_jobs = true
        VCR.use_cassette('jobs/filestreams/iiif_manifest_prewarm') do
          spec.run
        end
        ActiveJob::Base.queue_adapter.perform_enqueued_at_jobs = false
        ActiveJob::Base.queue_adapter.perform_enqueued_jobs = false
      end

      it 'sends a request to invalidate the IIIF cache' do
        subject.perform_later(job_args)
        expect(a_request(:get, iiif_manifest_url)).to have_been_made.at_least_once
      end
    end
  end
end