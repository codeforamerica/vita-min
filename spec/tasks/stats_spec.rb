require 'rails_helper'

describe 'stats:track_metrics' do
  include_context "rake"
  include MockDogapi

  around do |example|
    ActiveJob::Base.queue_adapter = :delayed_job
    example.run
    ActiveJob::Base.queue_adapter = :test
  end

  before do
    enable_datadog_and_stub_emit_point

    # Creating an OutgoingEmail immediately queues a job, this is here to make 2 delayed jobs
    create_list(:outgoing_email, 2)

    create(:efile_submission, :accepted)
    create(:efile_submission, :accepted)
    create(:efile_submission, :failed)
  end

  it 'reports some counts to datadog' do
    task.invoke

    expect(@emit_point_params).to match(array_including(
      ["vita-min.dogapi.delayed_job.queue_length", 2, tags: ["env:test"], type: "gauge"],
      ["vita-min.dogapi.delayed_job.queued_jobs", 2, tags: ["job_class:SendOutgoingEmailJob", "env:test"], type: "gauge"],
      ["vita-min.dogapi.efile_submissions.state_counts", 2, tags: ["current_state:accepted", "env:test"], type: "gauge"],
      ["vita-min.dogapi.efile_submissions.state_counts", 1, tags: ["current_state:failed", "env:test"], type: "gauge"]
    ))
  end
end
