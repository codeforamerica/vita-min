require "rails_helper"

RSpec.feature "Completing a state file intake" do
  let(:fake_xml) { "<haha>Your xml here</haha>" }
  before do
    allow_any_instance_of(Routes::StateFileDomain).to receive(:matches?).and_return(true)

    fake_response = SubmissionBuilder::Response.new(errors: [], document: fake_xml)
    allow_any_instance_of(
      SubmissionBuilder::Ty2022::States::Ny::IndividualReturn
    ).to receive(:build).and_return(fake_response)
    allow_any_instance_of(
      SubmissionBuilder::Ty2022::States::Az::IndividualReturn
    ).to receive(:build).and_return(fake_response)
  end

  context "NY" do
    it "has content" do
      visit "/"
      click_on "Start Test NY"

      expect(page).to have_text "The page with all the info from the 1040"

      # pretend to get federal data
      expect(find_field("tax return year").value).to be_nil
      click_on "Fetch 1040 data from IRS"
      expect(page).to have_field("tax return year", with: "2022")
      click_on "Continue"

      expect(page).to have_text "The page that shows your dependents"
      click_on "Continue"

      expect(page).to have_text "The page with all the info from the 201"
      click_on "Continue"

      expect(page).to have_text "The page with all the info from the IT-214"
      click_on "Continue"

      click_on "Submit My Fake Taxes"

      expect(page).to have_text "You have successfully submitted your taxes"
      click_on "Download XML"
      expect(page.body).to include(fake_xml)

      perform_enqueued_jobs
      submission = EfileSubmission.last
      expect(submission.submission_bundle).to be_present
      expect(submission.current_state).to eq("queued")
    end
  end

  context "AZ" do
    it "has content" do
      visit "/"
      click_on "Start Test AZ"
      click_on "Fetch 1040 data from IRS"
      click_on "Continue"
      click_on "Submit My Fake Taxes"
      expect(page).to have_text "You have successfully submitted your taxes"
      click_on "Download XML"
      expect(page.body).to include(fake_xml)

      perform_enqueued_jobs
      submission = EfileSubmission.last
      expect(submission.submission_bundle).to be_present
      expect(submission.current_state).to eq("queued")
    end
  end
end
