require "rails_helper"

RSpec.feature "Web Intake New Client wants to file on their own" do
  xscenario "a new client files through TaxSlayer" do
    visit "/questions/welcome"
    click_on "File taxes myself"

    expect(page).to have_selector("h1", text: "File your taxes yourself!")
    click_on "Continue"

    expect(page).to have_selector("h1", text: "Let's get started!")
    click_on "Continue"

    fill_in "ZIP Code", with: 90210
    click_on "Continue"

    fill_in "Email address", with: "test@example.com"
    fill_in "Confirm email address", with: "test@example.com"
    click_on "Continue to TaxSlayer"
  end
end
