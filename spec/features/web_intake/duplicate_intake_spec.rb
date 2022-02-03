require "rails_helper"

# this is a client that already has an intake
# different contact information
# same full SSN
# throw a duplicate check after collection full ssn
# clients can make on CTC client and once GYR client
# only for primary

RSpec.feature "Web Intake Duplicate Intake", :flow_explorer_screenshot, active_job: true do
  include MockTwilio

  let(:primary_ssn) { "123456789" }
  let!(:original_gyr_intake) do
    create :intake,
           primary_ssn: primary_ssn,
           email_address: "client@example.com",
           phone_number: "+18287654422",
           primary_consented_to_service: "yes",
           client: build(:client, tax_returns: [build(:tax_return, service_type: "online_intake")])
  end

  scenario "client sees a duplicate guard when they have already filed a GYR intake and try to file another one" do
    answer_gyr_triage_questions(choices: :defaults)
    click_on I18n.t('questions.triage_gyr.edit.file_online')
    # Ask about backtaxes
    check "#{TaxReturn.current_tax_year}"
    click_on "Continue"
    # creates intake
    intake = Intake.last
    click_on "Continue to example" # Non-production environment warning
    click_on "Continue" # Let's get started
    click_on "Continue" # Just a few simple steps to file

    # Personal Info
    expect(intake.reload.current_step).to eq("/en/questions/personal-info")
    expect(page).to have_selector("h1", text: "First, let's get some basic information.")
    fill_in "What is your preferred first name?", with: "Dupe"
    fill_in "Phone number", with: "8287654422"
    fill_in "Confirm phone number", with: "828-765-4422"
    fill_in "ZIP code", with: "20121"
    click_on "Continue"

    # Interview time preferences
    expect(intake.reload.current_step).to eq("/en/questions/interview-scheduling")
    fill_in "Do you have any time preferences for your interview phone call?", with: "Wednesday or Tuesday nights"
    expect(page).to have_select(
                      "What is your preferred language for the review?", selected: "English"
                    )
    select("Spanish", from: "What is your preferred language for the review?")
    click_on "Continue"

    # Notification Preference
    expect(intake.reload.current_step).to eq("/en/questions/notification-preference")
    expect(page).to have_text("What ways can we reach you")
    expect(page).to have_text("We’ll send a code to verify each contact method")
    check "Text Me"
    click_on "Continue"

    # Phone number can text
    expect(page).to have_text("Can we text the phone number you previously entered?")
    expect(page).to have_text("(828) 765-4422")
    expect(page).to have_text("Please be sure that this number can receive text messages.")
    click_on "Yes"

    # Verify cell phone contact
    expect(page).to have_selector("h1", text: "Let's verify that contact info with a code!")
    perform_enqueued_jobs
    sms = FakeTwilioClient.messages.last
    code = sms.body.to_s.match(/\s(\d{6})[.]/)[1]
    fill_in "Enter 6 digit code", with: code
    click_on "Verify"

    # Email
    expect(page).to have_selector("h1", text: "Please share your email address.")
    fill_in "Email address", with: "client@example.com"
    fill_in "Confirm email address", with: "client@example.com"
    click_on "Continue"

    # Consent form
    expect(page).to have_selector("h1", text: "Great! Here's the legal stuff...")
    fill_in "Legal first name", with: "Dupe"
    fill_in "Legal last name", with: "Gnome"
    fill_in I18n.t("attributes.primary_ssn"), with: primary_ssn
    fill_in I18n.t("attributes.confirm_primary_ssn"), with: primary_ssn
    select "March", from: "Month"
    select "5", from: "Day"
    select "1971", from: "Year"
    click_on "I agree"
    # expect not to create new tax return
    expect(intake.client.tax_returns.pluck(:year).sort).not_to eq [TaxReturn.current_tax_year]

    expect(page).to have_text "Looks like you’ve already started!"
  end
end
