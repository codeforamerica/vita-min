require "rails_helper"

RSpec.feature "Web Intake New Client with Questions" do
  scenario "new client not filing just has questions" do
    # Home
    visit "/"
    find("#firstCta").click

    # Welcome
    expect(page).to have_selector("h1", text: "Welcome! How can we help you?")
    click_on "Ask a question"

    # File With Help
    expect(current_path).to eq(tax_questions_path)
    expect(page).to have_selector("h1", text: "Let's try to answer your tax questions!")
    expect(page).to have_selector("button", text: "Chat with us")
  end
end

