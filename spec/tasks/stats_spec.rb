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

describe "stats:monitor_delayed_efile_submissions" do
  include_context "rake"
  include MockDogapi

  let(:fake_time) { DateTime.new(2022, 5, 10, 0, 0, 0) }
  let(:newer_timestamp_preparing) { 18.hours.ago }
  let(:timestamp_preparing) { 1.day.ago }
  let(:timestamp_bundling) { 14.hours.ago }
  let(:timestamp_queued) { 2.hours.ago }
  let(:newer_preparing_efile_submission) { create :efile_submission, :preparing }
  let(:preparing_efile_submission) { create :efile_submission, :preparing }
  let(:bundling_efile_submission) { create :efile_submission, :bundling, efile_submission_transitions: [create(:efile_submission_transition, :preparing, created_at: fake_time - 3.days, most_recent: false)] }
  let(:queued_efile_submission) { create :efile_submission, :queued }

  before do
    enable_datadog_and_stub_emit_point
    Timecop.freeze(fake_time) do
      newer_preparing_efile_submission.last_transition.update(created_at: newer_timestamp_preparing, most_recent: true)
      preparing_efile_submission.last_transition.update(created_at: timestamp_preparing, most_recent: true)
      bundling_efile_submission.last_transition.update(created_at: timestamp_bundling, most_recent: true)
      queued_efile_submission.last_transition.update(created_at: timestamp_queued, most_recent: true)
    end
  end

  it "reports the oldest efile submission transitions in the preparing, bundling, and queued states" do
    Timecop.freeze(fake_time) do
      task.invoke
    end
    expect(@emit_point_params).to match_array(
[
        ["vita-min.dogapi.efile_submissions.transition_latencies_minutes", 1440, tags: ["current_state:preparing", "env:test"], type: "gauge"],
        ["vita-min.dogapi.efile_submissions.transition_latencies_minutes", 840, tags: ["current_state:bundling", "env:test"], type: "gauge"],
        ["vita-min.dogapi.efile_submissions.transition_latencies_minutes", 120, tags: ["current_state:queued", "env:test"], type: "gauge"],
      ]
    )
  end
end
