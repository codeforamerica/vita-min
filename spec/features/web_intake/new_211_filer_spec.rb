require "rails_helper"

RSpec.feature "Web Intake 211 Assisted Filer" do
  let(:ticket_id) { 9876 }

  before do
    allow_any_instance_of(ZendeskIntakeService).to receive(:assign_requester)
    allow_any_instance_of(ZendeskIntakeService).to receive(:create_intake_ticket).and_return(ticket_id)
    # Create the hard-coded VITA partner for EIP-only returns
    create(:vita_partner, display_name: "Get Your Refund", zendesk_group_id: "360012655454")
  end

  scenario "new EIP-only client filing joint with a dependent" do
    # visit home with 211 source param
    visit "/211intake"
    visit "/en/questions/welcome"

    expect(page).to have_selector("h1", text: "Welcome! How can we help you?")
    click_on "File taxes with help"

    expect(page).to have_selector("h1", text: "File with the help of a tax expert!")
    click_on "Continue"

    # Intake created on backtaxes page
    expect(page).to have_selector("h1", text: "What years do you need to file for?")
    check "2019"
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

    # Skip to additional information
    visit "/questions/additional-info"
    fill_in "Is there any more information you think we should know?", with: "One of my kids moved away for college, should I include them as a dependent?"
    click_on "Next"

    # After additional info, navigation skips documents section and goes to interview time preferences
    fill_in "Do you have any time preferences for your interview phone call?", with: "Wednesday or Tuesday nights"
    expect(page) .to have_select(
      "What is your preferred language for the review?", selected: "English"
    )
    select("Spanish", from: "What is your preferred language for the review?")
    click_on "Continue"

    # Try to visit a page not in the flow and ensure it doesn't break from the progress calculation
    visit "/questions/overview-documents"
    expect(page).not_to have_selector(".progress-indicator__percentage")

    # Skip to additional information
    visit "/questions/successfully-submitted"
    expect{ track_progress }.to change { @current_progress }.to(100)

  end
end
