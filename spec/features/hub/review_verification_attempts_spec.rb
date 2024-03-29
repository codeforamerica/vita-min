require "rails_helper"

RSpec.feature "Clients who have been flagged for fraud" do
  let(:user) { create :admin_user, name: "Judith Juice" }
  let(:tina_verification_attempt) { create :verification_attempt, :pending }
  let(:catie_verification_attempt) { create :verification_attempt, :pending }
  let(:peter_verification_attempt) { create :verification_attempt, :pending }
  let(:restricted_verification_attempt) { create :verification_attempt, :restricted }

  before do
    login_as user

    tina_verification_attempt.client.intake.update(primary_first_name: "Tina", primary_last_name: "Tomato")
    catie_verification_attempt.client.intake.update(primary_first_name: "Catie", primary_last_name: "Cucumber")
    peter_verification_attempt.client.intake.update(primary_first_name: "Peter", primary_last_name: "Potato")

    fraud_score_double = instance_double(Fraud::Score)
    create :fraud_indicator, name: "recaptcha_score", indicator_type: "not_in_safelist"
    create :fraud_indicator, name: "timezone", indicator_type: "not_in_safelist"
    allow_any_instance_of(Hub::UpdateVerificationAttemptForm).to receive(:fraud_score).and_return fraud_score_double
    allow(fraud_score_double).to receive(:score).and_return(80)
    allow(fraud_score_double).to receive(:snapshot).and_return ({
        "recaptcha_score" => { "points" => 50, "data" => [0.3] },
        "timezone" => { "points" => 80, "data" => ["International/Timezone", "International/Timezone"] }
    })
  end

  scenario "As an admin, I can view a list of clients who have attempted to verify their identity" do
    # visit index page
    visit hub_verification_attempts_path

    # check number of records (does not display the restricted one)
    expect(page).to have_text "all 3 verification attempts"

    # check info in table
    within "#verification-attempt-#{tina_verification_attempt.id}" do
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
    expect(page).to have_text "International/Timezone, International/Timezone"
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
    visit hub_client_notes_path(client_id: tina_verification_attempt.client_id)

    expect(page).to have_content "#{user.name_with_role} approved verification attempt."
  end

  scenario "I can view, but not change status, on a restricted verification attempt" do
    visit hub_verification_attempt_path(id: restricted_verification_attempt.id)
    expect(page).to have_text "No action can be taken on this verification attempt because of its high fraud score."
  end

  scenario "I can escalate a verification attempt" do
    visit hub_verification_attempts_path

    # check info in table
    within "#verification-attempt-#{catie_verification_attempt.id}" do
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

    visit hub_client_notes_path(client_id: catie_verification_attempt.client_id)

    expect(page).to have_content "Judith Juice (Admin) escalated verification attempt for additional review."
  end

  scenario "I can deny a verification attempt" do
    visit hub_verification_attempts_path

    # check info in table
    within "#verification-attempt-#{catie_verification_attempt.id}" do
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

    visit hub_client_notes_path(client_id: catie_verification_attempt.client_id)

    expect(page).to have_content "Judith Juice (Admin) denied verification attempt."
  end

  scenario "I can request new photos for a verification attempt" do
    visit hub_verification_attempts_path

    # check info in table
    within "#verification-attempt-#{catie_verification_attempt.id}" do
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

    visit hub_client_notes_path(client_id: catie_verification_attempt.client_id)

    expect(page).to have_content "Judith Juice (Admin) requested new photos"
  end

  context "when a client has previous attempts" do
    let(:catie_verification_attempt_resubmission) { create :verification_attempt, :pending, client_id: catie_verification_attempt.client_id }
    before do
      catie_verification_attempt.transition_to(:requested_replacements)
      catie_verification_attempt_resubmission.client.intake.update(primary_first_name: "Catie", primary_last_name: "Cucumber")
    end

    scenario "I can see a client's previous verification attempts" do
      # visit index page
      visit hub_verification_attempts_path

      # check info in table
      within "#verification-attempt-#{catie_verification_attempt_resubmission.id}" do
        # check name
        expect(page).to have_text "Catie Cucumber"
        click_on "Catie Cucumber"
      end

      expect(page).to have_text "Previous Attempts"

      within "#previous-verification-attempt-#{catie_verification_attempt.id}" do
        expect(page).to have_text "requested replacements"
        expect(page).to have_selector("#time")
        click_on(id: "time")
      end

      # Original attempt should not include any other attempts
      expect(page).not_to have_selector("#previous-verification-attempt-#{catie_verification_attempt.id}")
      expect(page).not_to have_text "Previous Attempts"
    end
  end
end

