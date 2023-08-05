require "rails_helper"

RSpec.feature "Completing a state file intake" do
  before do
    allow_any_instance_of(Routes::StateFileDomain).to receive(:matches?).and_return(true)
  end

  it "has content" do
    visit "/"
    click_on "Start Test"
    click_on "Continue"
    click_on "Submit My Fake Taxes"

    perform_enqueued_jobs
    submission = EfileSubmission.last
    expect(submission.submission_bundle).to be_present
    expect(submission.current_state).to eq("queued")
  end
end
