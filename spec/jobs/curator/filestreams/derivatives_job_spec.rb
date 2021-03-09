# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/jobs_shared'
RSpec.describe Curator::Filestreams::DerivativesJob, type: :job do
  describe 'expected job behavior' do
    subject { described_class }

    let(:job_args) { create(:curator_filestreams_image) }
    let(:expected_queue) { 'filestream_derivatives' }

    before(:each) do
      ActiveJob::Base.queue_adapter = :test
    end

    it_behaves_like 'queueable'
  end
end
