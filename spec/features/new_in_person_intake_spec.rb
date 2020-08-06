require "rails_helper"

RSpec.feature "Add a new intake case from an in-person drop-off site" do
  before do
    zendesk_service_spy = instance_double(ZendeskDropOffService, create_ticket: 23, append_to_existing_ticket: true)
    allow(ZendeskDropOffService).to receive(:new).and_return(zendesk_service_spy)
  end

  scenario "new client" do
    visit "/thc/drop-off"
    expect(page).to have_text "Valet VITA Drop-off"

    select "Lamar Community College", from: "Intake Site"
    expect(page).to have_select("State", selected: "Colorado")
    select "Nevada", from: "State"
    fill_in "Client name", with: "Jane Jackfruit"
    fill_in "Client email", with: "jjackfruit@example.com"
    fill_in "Client phone number", with: "415-816-1286"
    expect(page).to have_text "Pick-up method"
    choose "In-person"
    expect(page).to have_text "M/D"
    fill_in "Pick-up date", with: "2/20"
    attach_file("Documents bundle", "spec/fixtures/attachments/document_bundle.pdf")
    choose "Advanced"
    check "HSA"
    fill_in "Additional information", with: "Needs to double check if they have another W-2"

    click_on "Send for prep"

    expect(page).to have_text "New drop-off sent for prep!"
    expect(page).to have_text "Zendesk Ticket ID: 23"

    click_on "Add another drop-off"

    expect(page).to have_text "Valet VITA Drop-off"
    expect(page).to have_select("Intake Site", selected: "Lamar Community College")
  end

  scenario "returning client" do
    create :intake_site_drop_off, email: "jjackfruit@example.com", zendesk_ticket_id: "35"

    visit "/thc/drop-off"
    expect(page).to have_text "Valet VITA Drop-off"

    select "Lamar Community College", from: "Intake Site"
    fill_in "Client name", with: "Jane Jackfruit"
    fill_in "Client email", with: "jjackfruit@example.com"
    fill_in "Client phone number", with: "415-816-1286"
    expect(page).to have_text "Pick-up method"
    choose "In-person"
    expect(page).to have_text "M/D"
    fill_in "Pick-up date", with: "2/20"
    attach_file("Documents bundle", "spec/fixtures/attachments/document_bundle.pdf")
    fill_in "Additional information", with: "Needs to double check if they have another W-2"

    click_on "Send for prep"

    expect(page).to have_text "Found a matching Zendesk ticket!"
    expect(page).to have_text "Comment with details added to ticket ID: 35"

    click_on "Add another drop-off"

    expect(page).to have_text "Valet VITA Drop-off"
  end
end