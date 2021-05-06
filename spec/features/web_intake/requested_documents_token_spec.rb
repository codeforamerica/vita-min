require "rails_helper"

RSpec.feature "Client uploads a requested document" do
  scenario "client goes to the follow up documents token link, it redirects to login" do
    visit "/documents/add/1234ABCDEF"

    expect(page).to have_selector("h1", text: "To view your progress, we’ll send you a secure code.")
  end
end
