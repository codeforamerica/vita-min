require "rails_helper"

RSpec.feature "Clients who have been flagged for fraud" do
  let(:user) { create :admin_user, name: "Judith Juice" }
  let(:verification_attempt_1) { create :verification_attempt }
  let(:verification_attempt_2) { create :verification_attempt }
  let(:verification_attempt_3) { create :verification_attempt }
  let(:verification_attempt_4) { create :verification_attempt, client_id: verification_attempt_2.client_id }

  before do
    login_as user

    verification_attempt_1.client.intake.update(primary_first_name: "Tina", primary_last_name: "Tomato")
    verification_attempt_2.client.intake.update(primary_first_name: "Catie", primary_last_name: "Cucumber")
    verification_attempt_3.client.intake.update(primary_first_name: "Peter", primary_last_name: "Potato")
    verification_attempt_4.client.intake.update(primary_first_name: "Catie", primary_last_name: "Cucumber")

    fake_fraud_service = instance_double(FraudIndicatorService)
    allow(FraudIndicatorService).to receive(:new).and_return(fake_fraud_service)
    allow(fake_fraud_service).to receive(:hold_indicators).and_return ["recaptcha_score", "international_timezone"]
    allow(fake_fraud_service).to receive(:fraud_suspected?)
  end

  scenario "As an admin, I can view a list of clients who have attempted to verify their identity" do
    # visit index page
    visit hub_verification_attempts_path

    # check number of records
    expect(page).to have_text "all 4 verification attempts"

    # check info in table
    within "#verification-attempt-#{verification_attempt_1.id}" do
      # check name
      click_on "Tina Tomato"
    end

    # check that items are sorted correctly

    # viewing an individual verification attempt
    # - click on a verification attempt


    # - check info on show page
    #   - check name
    expect(page).to have_text "Tina Tomato"
    #   - check list of fraud flags
    expect(page).to have_text "Recaptcha score"
    expect(page).to have_text "International timezone"
    #   - check document uploads
    expect(page).to have_selector("img#selfie")
    expect(page).to have_selector("img#photo_id")

    expect(page).to have_selector("input#approve")
    expect(page).to have_selector("input#deny")
    expect(page).to have_selector("input#escalate")
    expect(page).to have_selector("input#request_replacement")

    # - create note + approve
    fill_in "Add a new note", with: "These are my notes"
    click_on "Approve"

    within "ul#verification-attempt-notes" do
      expect(page).to have_text "#{user.name_with_role} approved verification attempt."
      expect(page).to have_text "These are my notes"
    end

    expect(page).not_to have_selector("input#approve")
    expect(page).not_to have_selector("input#deny")
    expect(page).not_to have_selector("input#escalate")
    expect(page).not_to have_selector("input#request_replacement")

    # Go to client notes page and make sure there is a record of the note there as well
    visit hub_client_notes_path(client_id: verification_attempt_1.client_id)

    expect(page).to have_content "#{user.name_with_role} approved verification attempt."
  end

  scenario "I can escalate a verification attempt" do
    visit hub_verification_attempts_path

    # check info in table
    within "#verification-attempt-#{verification_attempt_2.id}" do
      # check name
      click_on "Catie Cucumber"
    end

    expect(page).to have_selector("input#deny")
    expect(page).to have_selector("input#approve")
    expect(page).to have_selector("input#escalate")

    click_on "Escalate"
    expect(page).to have_text "A note is required when escalating a verification attempt."

    fill_in "Add a new note", with: "This is a racoon! Not Catie Cucumber!"
    click_on "Escalate"

    within "ul#verification-attempt-notes" do
      expect(page).to have_text "Judith Juice (Admin) escalated verification attempt."
      expect(page).to have_text "This is a racoon! Not Catie Cucumber!"
    end

    expect(page).to have_selector("input#deny")
    expect(page).to have_selector("input#approve")
    expect(page).to have_selector("textarea#hub_update_verification_attempt_form_note")
    expect(page).not_to have_selector("input#escalate")

    visit hub_client_notes_path(client_id: verification_attempt_2.client_id)

    expect(page).to have_content "Judith Juice (Admin) escalated verification attempt for additional review."
  end

  scenario "I can escalate a verification attempt" do
    visit hub_verification_attempts_path

    # check info in table
    within "#verification-attempt-#{verification_attempt_2.id}" do
      # check name
      click_on "Catie Cucumber"
    end

    expect(page).to have_selector("input#deny")
    expect(page).to have_selector("input#approve")
    expect(page).to have_selector("input#escalate")
    expect(page).to have_selector("input#request_replacement")

    click_on "Escalate"
    expect(page).to have_text "A note is required when escalating a verification attempt."

    fill_in "Add a new note", with: "This is a racoon! Not Catie Cucumber!"
    click_on "Escalate"

    within "ul#verification-attempt-notes" do
      expect(page).to have_text "Judith Juice (Admin) escalated verification attempt."
      expect(page).to have_text "This is a racoon! Not Catie Cucumber!"
    end

    expect(page).to have_selector("input#deny")
    expect(page).to have_selector("input#approve")
    expect(page).to have_selector("textarea#hub_update_verification_attempt_form_note")
    expect(page).to have_selector("input#request_replacement")
    expect(page).not_to have_selector("input#escalate")

    visit hub_client_notes_path(client_id: verification_attempt_2.client_id)

    expect(page).to have_content "Judith Juice (Admin) escalated verification attempt for additional review."
  end

  scenario "I can deny a verification attempt" do
    visit hub_verification_attempts_path

    # check info in table
    within "#verification-attempt-#{verification_attempt_2.id}" do
      # check name
      click_on "Catie Cucumber"
    end

    expect(page).to have_selector("input#deny")
    expect(page).to have_selector("input#approve")
    expect(page).to have_selector("input#escalate")
    expect(page).to have_selector("input#request_replacement")

    fill_in "Add a new note", with: "This is a racoon! Not Catie Cucumber!"
    click_on "Deny and Close"

    within "ul#verification-attempt-notes" do
      expect(page).to have_text "Judith Juice (Admin) denied verification attempt."
      expect(page).to have_text "This is a racoon! Not Catie Cucumber!"
    end

    expect(page).not_to have_selector("textarea#hub_update_verification_attempt_form_note")
    expect(page).not_to have_selector("input#deny")
    expect(page).not_to have_selector("input#approve")
    expect(page).not_to have_selector("input#request_replacement")

    visit hub_client_notes_path(client_id: verification_attempt_2.client_id)

    expect(page).to have_content "Judith Juice (Admin) denied verification attempt."
  end

  scenario "I can request new photos for a verification attempt" do
    visit hub_verification_attempts_path

    # check info in table
    within "#verification-attempt-#{verification_attempt_2.id}" do
      # check name
      click_on "Catie Cucumber"
    end

    expect(page).to have_selector("input#deny")
    expect(page).to have_selector("input#approve")
    expect(page).to have_selector("input#escalate")
    expect(page).to have_selector("input#request_replacement")

    fill_in "Add a new note", with: "This is a picture of a racoon! Not Catie Cucumber!"
    click_on "Request replacement photos"

    within "ul#verification-attempt-notes" do
      expect(page).to have_text "Judith Juice (Admin) requested new photos"
      expect(page).to have_text "This is a picture of a racoon! Not Catie Cucumber!"
    end

    expect(page).not_to have_selector("textarea#hub_update_verification_attempt_form_note")
    expect(page).not_to have_selector("input#deny")
    expect(page).not_to have_selector("input#approve")
    expect(page).not_to have_selector("input#request_replacement")

    visit hub_client_notes_path(client_id: verification_attempt_2.client_id)

    expect(page).to have_content "Judith Juice (Admin) requested new photos"
  end

  scenario "I can see a client's previous verification attempts" do
    # visit index page
    visit hub_verification_attempts_path

    # check info in table
    within "#verification-attempt-#{verification_attempt_4.id}" do
      # check name
      expect(page).to have_text "Catie Cucumber"
      click_on "Catie Cucumber"
    end

    expect(page).to have_text "Previous Attempts"

    within "#previous-verification-attempt-#{verification_attempt_2.id}" do
      expect(page).to have_text "pending"
      expect(page).to have_selector("#time")
      click_on(id: "time")
    end

    # Original attempt should not include any other attempts
    expect(page).not_to have_selector("#previous-verification-attempt-#{verification_attempt_2.id}")
    expect(page).not_to have_text "Previous Attempts"

    expect(page).to have_selector("input#deny")
    expect(page).to have_selector("input#approve")
    expect(page).to have_selector("input#escalate")
    expect(page).to have_selector("input#request_replacement")
  end
end

