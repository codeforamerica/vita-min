require "rails_helper"

RSpec.feature "Web Intake Single Filer" do
  before do
    create(
      :intake,
      email_address: "returning@client.com",
      intake_pdf_sent_to_zendesk: "yes"
    )
  end

  scenario "returning client tries filing again is taken to returning client signpost page" do
    visit already_filed_questions_path
    click_on "Yes"

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
