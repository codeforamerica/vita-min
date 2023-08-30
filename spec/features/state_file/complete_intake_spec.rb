require "rails_helper"

RSpec.feature "Completing a state file intake" do
  before do
    allow_any_instance_of(Routes::StateFileDomain).to receive(:matches?).and_return(true)
  end

  it "has content" do
    visit "/"
    click_on "Start Test NY"

    expect(page).to have_text "The page with all the info from the 1040"
    click_on "Continue"

    expect(page).to have_text "The page that shows your dependents"
    click_on "Continue"

    expect(page).to have_text "The page with all the info from the 201"
    click_on "Continue"

    click_on "Submit My Fake Taxes"

    perform_enqueued_jobs
    submission = EfileSubmission.last
    expect(submission.submission_bundle).to be_present
    expect(submission.current_state).to eq("queued")
  end

  it "has content" do
    visit "/"
    click_on "Start Test AZ"
    click_on "Continue"
    click_on "Submit My Fake Taxes"

    perform_enqueued_jobs
    submission = EfileSubmission.last
    expect(submission.submission_bundle).to be_present
    expect(submission.current_state).to eq("queued")
  end
end
