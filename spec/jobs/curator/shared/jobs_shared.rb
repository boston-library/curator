# frozen_string_literal: true

RSpec.shared_examples 'queueable', type: :job do
  it 'queues the job' do
    expect do
      subject.perform_later(job_args)
    end.to have_enqueued_job.with(job_args).on_queue(expected_queue).at(:no_wait)
  end
end
