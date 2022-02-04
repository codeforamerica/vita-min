require "rails_helper"

RSpec.feature "Web Intake Single Filer", :flow_explorer_screenshot do
  before do
    create(
      :intake,
      email_address: "returning@client.com",
      primary_consented_to_service: "yes",
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
end
