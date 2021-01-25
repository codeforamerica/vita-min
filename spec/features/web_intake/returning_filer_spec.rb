require "rails_helper"

RSpec.feature "Web Intake Single Filer" do
  before do
    create(
      :intake,
      email_address: "returning@client.com",
      primary_consented_to_service: "yes",
    )
  end

  scenario "returning client tries filing again is taken to returning client signpost page" do
    visit backtaxes_questions_path
    check "2019"
    click_on "Continue"

    visit email_address_questions_path
    expect(page).to have_selector("h1", text: "Please share your e-mail address.")
    fill_in "E-mail address", with: "returning@client.com"
    fill_in "Confirm e-mail address", with: "returning@client.com"
    click_on "Continue"

    expect(current_path).to eq(returning_client_questions_path)
    click_on("Return to home")
    expect(current_path).to eq(root_path)
  end
end
