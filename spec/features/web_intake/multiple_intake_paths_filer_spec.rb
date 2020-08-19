require "rails_helper"

RSpec.feature "Web Intake Filer Tries Multiple Intake Paths" do
  scenario "new client goes back to beginning of intake in same session before submitting" do
    # Skip to EIP overview
    visit "/questions/eip-overview"

    expect(page).to have_selector("h1", text: "Great! Let's help you collect your stimulus.")
    click_on "Continue"

    # Intake with eip_only: true has been created

    # Skip to welcome page with options (DIY, full service, etc.)
    visit "/questions/welcome"
    expect(page).to have_selector("h1", text: "Welcome! How can we help you?")
    click_on "File taxes with help"

    expect(page).to have_selector("h1", text: "File with the help of a tax expert!")
    click_on "Continue"

    # Doesn't get stuck trying to do full service flow
    expect(page).to have_selector("h1", text: "What years do you need to file for?")

    check "2017"
    check "2019"
    click_on "Continue"

    # Non-production environment warning
    expect(page).to have_selector("h1", text: "Thanks for visiting the GetYourRefund demo application!")
    click_on "Continue to example"
  end
end