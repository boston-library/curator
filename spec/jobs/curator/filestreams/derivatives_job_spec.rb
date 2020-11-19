# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Curator::Filestreams::DerivativesJob, type: :job do
  describe 'expected job behavior' do
    subject { described_class }

    let!(:file_set_class) { 'Curator::Filestreams::Image' }
    let!(:file_set_id) { 1 }
    let!(:expected_queue) { 'filestream_derivatives' }

    before(:each) do
      ActiveJob::Base.queue_adapter = :test
    end

    it 'is expected to have been enqueued with correct args' do
      subject.perform_later(file_set_class, file_set_id)
      expect(subject).to have_been_enqueued.with(file_set_class, file_set_id)
    end

    it 'is expected to have been enqueued on correct queue' do
      subject.perform_later(file_set_class, file_set_id)
      expect(subject).to have_been_enqueued.on_queue(expected_queue)
    end

    it 'is expected to be enqueued immediatley' do
      subject.perform_later(file_set_class, file_set_id)
      expect(subject).to have_been_enqueued.at(:no_wait)
    end
  end
end
