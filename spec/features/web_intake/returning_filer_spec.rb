require "rails_helper"

RSpec.feature "Web Intake Single Filer", :flow_explorer_screenshot do
  let(:primary_ssn) { "123456789" }
  let!(:original_intake) { create :intake, email_address: "original@client.com", phone_number: "+14155537865", primary_consented_to_service: "yes", primary_ssn: primary_ssn, client: build(:client, tax_returns: [build(:tax_return, service_type: "online_intake")]) }
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

  scenario "returning client tries filing again is taken to returning client signpost page" do
    visit backtaxes_questions_path
    check "2019"
    click_on "Continue"

    visit email_address_questions_path
    expect(page).to have_selector("h1", text: "Please share your email address.")
    fill_in "Email address", with: "returning@client.com"
    fill_in "Confirm email address", with: "returning@client.com"
    click_on "Continue"

    expect(current_path).to eq(returning_client_questions_path)
    within "main" do
      click_on("Sign in")
    end
    expect(current_path).to eq(new_portal_client_login_path)
  end

  scenario "returning client tries filing again is taken to returning client signpost page when duplicate ssn" do
    visit backtaxes_questions_path
    check "2019"
    click_on "Continue"

    visit consent_questions_path
    fill_in "Legal first name", with: "Dupe"
    fill_in "Legal last name", with: "Gnome"
    fill_in I18n.t("attributes.primary_ssn"), with: primary_ssn
    fill_in I18n.t("attributes.confirm_primary_ssn"), with: primary_ssn
    select "March", from: "Month"
    select "5", from: "Day"
    select "1971", from: "Year"
    click_on "I agree"

    expect(page).to have_text "Looks like you’ve already started!"
    expect(current_path).to eq(returning_client_questions_path)
  end
end
