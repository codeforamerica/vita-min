require "rails_helper"

RSpec.feature "Web Intake EIP Only Filer" do
  before do
    # Create the hard-coded VITA partner for EIP-only returns
    create :vita_partner, name: "Get Your Refund", national_overflow_location: true
  end
  
  scenario "ineligible for EIP" do
    visit "/questions/eip-overview"
    expect(page).to have_selector("h1", text: "Great! Let's help you collect your stimulus.")
    click_on "Continue"

    # Non-production environment warning
    expect(page).to have_selector("h1", text: "Thanks for visiting the GetYourRefund demo application!")
    click_on "Continue to example"

    # Eligibility Page
    expect(page).to have_selector("h1", text: "Before we start, let's make sure you qualify for our help!")
    check "Someone else is claiming me on their taxes"
    click_on "Collect my stimulus"

    # Offboarding page
    expect(page).to have_selector("h1", text: "Unfortunately, you don't qualify for our assistance")
    click_on "Visit Stimulus FAQ"

    # Stimulus FAQ
    expect(page).to have_selector("h1", text: "Get your Stimulus Check")
  end
end
