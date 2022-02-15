require "rails_helper"

RSpec.feature "Clients who have been flagged for fraud" do
  let(:user) { create :admin_user, name: "Judith Juice" }
  let!(:note) { create :verification_attempt_transition, :escalated, metadata: { initiated_by_id: user.id, note: "this client looks like a racoon" }, verification_attempt: verification_attempt_1 }
  let(:verification_attempt_1) { create :verification_attempt }
  let(:verification_attempt_2) { create :verification_attempt }
  let(:verification_attempt_3) { create :verification_attempt }

  before do
    login_as user

    verification_attempt_1.client.intake.update(primary_first_name: "Tina", primary_last_name: "Tomato")
    verification_attempt_2.client.intake.update(primary_first_name: "Catie", primary_last_name: "Cucumber")
    verification_attempt_3.client.intake.update(primary_first_name: "Peter", primary_last_name: "Potato")


    fake_fraud_service = instance_double(FraudIndicatorService)
    allow(FraudIndicatorService).to receive(:new).and_return(fake_fraud_service)
    allow(fake_fraud_service).to receive(:hold_indicators).and_return ["recaptcha_score", "international_timezone"]
    allow(fake_fraud_service).to receive(:fraud_suspected?)
  end

  scenario "As an admin, I can view a list of clients who have attempted to verify their identity" do
    # visit index page
    visit hub_verification_attempts_path

    # check number of records
    expect(page).to have_text "3 clients to be verified"

    # check info in table
    within "#verification-attempt-#{verification_attempt_1.id}" do
      # check name
      expect(page).to have_text "Tina Tomato"
    end

    # check that items are sorted correctly

    # viewing an individual verification attempt
    # - click on a verification attempt
    click_on "Tina"

    # - check info on show page
    #   - check name
    expect(page).to have_text "Tina Tomato"
    #   - check list of fraud flags
    expect(page).to have_text "Recaptcha score"
    expect(page).to have_text "International timezone"
    #   - check document uploads
    expect(page).to have_selector("img#selfie")
    expect(page).to have_selector("img#photo_id")

    #   - check notes
    expect(page).to have_text "this client looks like a racoon"

    # - create note
    fill_in "Add a new note", with: "These are my notes"
    click_on "Approve"

    within "ul#verification-attempt-notes" do
      expect(page).to have_text "Judith Juice - Admin approved verification attempt."
      expect(page).to have_text "These are my notes"
    end

    # Go to client notes page and make sure there is a record of the note there as well
    visit hub_client_notes_path(client_id: verification_attempt_1.client_id)

    expect(page).to have_content "Judith Juice - Admin approved verification attempt."
  end
end
