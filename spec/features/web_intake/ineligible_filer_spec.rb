require "rails_helper"

RSpec.feature "client is not eligible for VITA services" do
  scenario "client checks one of the boxes on the triage_eligibility page" do
    visit "/en/questions/welcome"

    expect(page).to have_selector("h1", text: "Welcome to GetYourRefund")
    click_on "Continue"

    # File With Help
    # Tax Needs
    expect(page).to have_selector("h1", text: "What can we help you with?")
    check "File my 2020 taxes"
    click_on "Continue"

    expect(page).to have_selector("h1", text: "Yes, our service is completely free. Let's make sure you qualify.")

    expect(page).to have_selector("p", text: "Let us know if any of the situations below apply to you.")
    check "I earned money from a rental property"
    click_on "Continue"

    expect(page).to have_selector("h1", text: "We’re unsure if you qualify for our services")
    click_on "Go back"
  end
end
