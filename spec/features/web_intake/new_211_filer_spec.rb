require "rails_helper"

RSpec.feature "Web Intake 211 Assisted Filer", :flow_explorer_screenshot do
  before do
    # Create the hard-coded VITA partner for EIP-only returns
    create(:organization, name: "Get Your Refund")
  end

  scenario "new EIP-only client filing joint with a dependent" do
    # visit home with 211 source param
    visit "/211intake"
    visit "/en/questions/file-with-help"

    expect(page).to have_selector("h1", text: "Our full service option is right for you!")
    click_on "Continue"

    # Intake created on backtaxes page
    expect(page).to have_selector("h1", text: "What years would you like to file for?")
    check "2019"
    click_on "Continue"

    # interview time preference
    visit "/questions/interview-scheduling"
    fill_in "Do you have any time preferences for your interview phone call?", with: "Wednesday or Tuesday nights"
    expect(page).to have_select(
      "What is your preferred language for the review?", selected: "English"
    )
    select("Spanish", from: "What is your preferred language for the review?")
    click_on "Continue"

    # Skip to consent to create ticket
    visit "/questions/consent"
    expect(page).to have_selector("h1", text: "Great! Here's the legal stuff...")
    fill_in "Legal first name", with: "Gary"
    fill_in "Legal last name", with: "Gnome"
    fill_in "Last 4 of SSN/ITIN", with: "1234"
    select "March", from: "Month"
    select "5", from: "Day"
    select "1971", from: "Year"
    click_on "I agree"

    # Skip to mailing address
    visit "/questions/mailing-address"
    fill_in "Street address", with: "123 Main St."
    fill_in "City", with: "Anytown"
    select "California", from: "State"
    fill_in "ZIP code", with: "94612"
    click_on "Confirm"

    # After mailing address skips documents section and goes to final info page
    expect(Intake.last.current_step).to eq("/en/questions/final-info")

    # Try to visit a page not in the flow and ensure it doesn't break from the progress calculation
    visit "/questions/overview-documents"
    expect(page).not_to have_selector(".progress-indicator__percentage")

    # Skip to additional information
    visit "/questions/successfully-submitted"
    expect{ track_progress }.to change { @current_progress }.to(100)

  end
end
