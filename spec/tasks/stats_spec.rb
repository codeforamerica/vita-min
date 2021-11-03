require 'rails_helper'

describe 'stats:track_metrics' do
  include_context "rake"

  let(:fake_dogapi) { instance_double(Dogapi::Client) }

  around do |example|
    ActiveJob::Base.queue_adapter = :delayed_job
    example.run
    ActiveJob::Base.queue_adapter = :test
  end

  before do
    DatadogApi.configure do |c|
      allow(c).to receive(:enabled).and_return(true)
    end

    allow(Dogapi::Client).to receive(:new).and_return(fake_dogapi)
    @emit_point_params = []
    allow(fake_dogapi).to receive(:emit_point) do |*params|
      @emit_point_params << params
    end

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
      ["vita-min.dogapi.efile_submissions.state_counts", 2, tags: ["current_state:accepted", "env:test"], type: "gauge"],
      ["vita-min.dogapi.efile_submissions.state_counts", 1, tags: ["current_state:failed", "env:test"], type: "gauge"]
    ))
  end
end
