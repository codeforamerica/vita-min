require "rails_helper"

RSpec.feature "Web Intake Single Filer", :flow_explorer_screenshot do
  let(:primary_ssn) { "123456789" }
  let!(:original_intake) { create :intake, email_address: "original@client.com", phone_number: "+14155537865", primary_consented_to_service: "yes", primary_ssn: primary_ssn, client: build(:client, tax_returns: [build(:tax_return, service_type: "online_intake")]) }
  let!(:ctc_intake_matching_ssn) { create :ctc_intake, primary_consented_to_service: "yes", primary_ssn: primary_ssn }
  before do
    create(
      :intake,
      email_address: "dupe@client.com",
      phone_number: "+18285537865",
      primary_consented_to_service: "yes",
      primary_ssn: primary_ssn,
      client: build(:client, tax_returns: [build(:tax_return, service_type: "online_intake")])
    )
  end

  scenario "returning client tries filing again is taken to returning client signpost page when a GYR intake with matching ssn exists" do
    visit backtaxes_questions_path
    check "2019"
    click_on "Continue"

    visit personal_info_questions_path
    expect(page).to have_selector("h1", text: "First, let's get some basic information.")
    fill_in "What is your preferred first name?", with: "Dupe"
    fill_in "Phone number", with: "8286345533"
    fill_in "Confirm phone number", with: "828-634-5533"
    fill_in I18n.t("attributes.primary_ssn"), with: primary_ssn
    fill_in I18n.t("attributes.confirm_primary_ssn"), with: primary_ssn
    fill_in "ZIP code", with: "20121"
    click_on "Continue"

    expect(page).to have_text "Looks like you’ve already started!"
    expect(current_path).to eq(returning_client_questions_path)

    within "main" do
      click_on("Sign in")
    end
    expect(current_path).to eq(new_portal_client_login_path)
  end

  #scenario for a matching ITIN

  scenario "client with matching CTC intake & no matching GYR intake doesn't see GYR duplicate guard" do
    visit backtaxes_questions_path
    check "2019"
    click_on "Continue"

    visit personal_info_questions_path
    expect(page).to have_selector("h1", text: "First, let's get some basic information.")
    fill_in "What is your preferred first name?", with: "Dupe"
    fill_in "Phone number", with: "8286345533"
    fill_in "Confirm phone number", with: "828-634-5533"
    fill_in I18n.t("attributes.primary_ssn"), with: "987654321"
    fill_in I18n.t("attributes.confirm_primary_ssn"), with: "987654321"
    fill_in "ZIP code", with: "20121"
    click_on "Continue"

    expect(page).not_to have_text "Looks like you’ve already started!"
    expect(current_path).not_to eq(returning_client_questions_path)
  end
end
