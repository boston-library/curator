# frozen_string_literal: true

require 'rails_helper'
require_relative './shared/jobs_shared'

RSpec.describe Curator::ArkDeleteJob, type: :job do

  describe 'expected job behavior' do
    subject { described_class }

    let(:job_args) { 'bpl-dev:987654321' }
    let(:expected_queue) { :arks }
    let(:ark_manager_destroy_url) { "#{Curator.config.ark_manager_api_url}/api/v2/#{job_args}" }

    before(:each) do
      ActiveJob::Base.queue_adapter = :test
    end

    it_behaves_like 'queueable'

    skip 'sends a delete request to the indexing service' do
      ActiveJob::Base.queue_adapter.perform_enqueued_jobs = true
      subject.perform_later(job_args)
      assert_requested :delete, ark_manager_destroy_url
    end
  end
end
