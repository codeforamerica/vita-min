require "rails_helper"

RSpec.feature "Completing a state file intake" do
  let(:fake_xml) { "<haha>Your xml here</haha>" }
  before do
    allow_any_instance_of(Routes::StateFileDomain).to receive(:matches?).and_return(true)
  end

  context "NY", :flow_explorer_screenshot do
    it "has content" do
      visit "/"
      click_on "Start Test NY"

      expect(page).to have_text "File your New York state taxes for free"
      click_on "Get Started", id: "firstCta"

      expect(page).to have_text "Log in"
      fill_in "Email", with: "kermit@example.com"
      fill_in "Password", with: "therainbowconnection"
      click_on "Continue"

      expect(page).to have_text "The page with all the info from the 1040"

      # pretend to get federal data
      expect(find_field("tax return year").value).not_to be_present
      click_on "Fetch 1040 data from IRS"
      expect(page).to have_field("tax return year", with: "2022")
      click_on "Continue"

      expect(page).to have_text "Was this your permanent home address on December 31, 2023?"
      choose "Yes"
      click_on "Continue"

      expect(page).to have_text "The page that shows your dependents"
      expect(page).to have_text "TESSA TESTERSON"
      click_on "Continue"

      expect(page).to have_text "The page with all the info from the 201"
      click_on "Continue"

      expect(page).to have_text "The page with all the info from the IT-214"
      click_on "Continue"

      click_on "Submit My Fake Taxes"

      expect(page).to have_text "You have successfully submitted your taxes"
      expect(page).to have_link "Download PDF"
      click_on "Show XML"
      expect(page.body).to include('efile:ReturnState')
      expect(page.body).to include('<ABA_NMBR claimed="013456789"/>')
      expect(page.body).to include('<BANK_ACCT_NMBR claimed="456789008765"/>')

      perform_enqueued_jobs
      submission = EfileSubmission.last
      # Asserting on metadata so we can get a good error if bundling starts to fail
      # (the metadata will include error_code and raw_response)
      expect(submission.last_transition.metadata).to eq({})
      expect(submission.submission_bundle).to be_present
      expect(submission.current_state).to eq("queued")
    end
  end

  context "AZ", :flow_explorer_screenshot do
    it "has content" do
      visit "/"
      click_on "Start Test AZ"

      expect(page).to have_text "File your Arizona state taxes for free"
      click_on "Get Started", id: "firstCta"

      expect(page).to have_text "Log in"
      fill_in "Email", with: "kermit@example.com"
      fill_in "Password", with: "therainbowconnection"
      click_on "Continue"

      click_on "Fetch 1040 data from IRS"
      click_on "Continue"

      expect(page).to have_text "The page that shows your dependents"
      expect(page).to have_text "TESSA TESTERSON"
      click_on "Continue"

      click_on "Submit My Fake Taxes"
      expect(page).to have_text "You have successfully submitted your taxes"
      click_on "Show XML"
      expect(page.body).to include('efile:ReturnState')
      expect(page.body).to include('<FirstName>Testy</FirstName>')

      perform_enqueued_jobs
      submission = EfileSubmission.last
      expect(submission.submission_bundle).to be_present
      expect(submission.current_state).to eq("queued")
    end
  end
end
