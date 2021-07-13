# frozen_string_literal: true

RSpec.shared_examples 'queueable', type: :job do
  describe 'expected job enqueued' do
    around(:each) do |spec|
      ActiveJob::Base.queue_adapter = :test
      ActiveJob::Base.queue_adapter.perform_enqueued_jobs = false
      spec.run
    end

    it 'enqueues the job' do
      expect do
        subject.perform_later(job_args)
      end.to have_enqueued_job.with(job_args).on_queue(expected_queue).at(:no_wait)
    end
  end
end
