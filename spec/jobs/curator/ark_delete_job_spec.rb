# frozen_string_literal: true

require 'rails_helper'
require_relative './shared/jobs_shared'

RSpec.describe Curator::ArkDeleteJob, type: :job do
  describe 'expected job behavior' do
    subject { described_class }

    let(:job_args) { 'bpl-dev:987654321' }
    let(:expected_queue) { 'arks' }

    it_behaves_like 'queueable'

    describe '#perform_later' do
      let(:ark_manager_destroy_url) { "#{Curator.config.ark_manager_api_url}/api/v2/arks/#{job_args}" }

      around(:each) do |spec|
        ActiveJob::Base.queue_adapter = :test
        ActiveJob::Base.queue_adapter.perform_enqueued_jobs = true
        VCR.use_cassette('jobs/ark_delete_job') do
          spec.run
        end
      end

      it 'sends a delete request to the indexing service' do
        subject.perform_later(job_args)
        expect(a_request(:delete, ark_manager_destroy_url)).to have_been_made.at_least_once
      end
    end
  end
end
