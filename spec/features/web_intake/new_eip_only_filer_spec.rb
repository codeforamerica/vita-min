require "rails_helper"

RSpec.feature "Web Intake EIP Only Filer" do
  scenario "new EIP-only client filing joint with a dependent" do
    visit "/en/questions/welcome"

    # Welcome
    expect(page).to have_selector("h1", text: "Welcome! How can we help you?")
    expect(page).not_to have_selector("h2", text: "Get your Stimulus")
  end
end
