# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/jobs_shared'
RSpec.describe Curator::Filestreams::DerivativesJob, type: :job do
  describe 'expected job behavior' do
    subject { described_class }

    let!(:file_stream) { create(:curator_filestreams_image) }

    let(:job_args) { [file_stream.class.name, file_stream.id] }
    let(:expected_queue) { 'filestream_derivatives' }

    it_behaves_like 'queueable'
  end
end
