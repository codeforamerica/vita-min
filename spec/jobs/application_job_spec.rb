require 'rails_helper'

describe ApplicationJob do
  before do
    SampleJobClass = Class.new(ApplicationJob) do
      def perform(object_id)
        return true
      end
    end
  end

  around do |example|
    ActiveJob::Base.queue_adapter = :delayed_job
    example.run
    ActiveJob::Base.queue_adapter = :test
  end

  it 'persists job class and arguments to the delayed_jobs table' do
    SampleJobClass.perform_later(123)
    delayed_job = Delayed::Job.last
    expect(delayed_job.job_class).to eq(SampleJobClass.to_s)
    expect(delayed_job.job_object_id).to eq(123)
  end
end
