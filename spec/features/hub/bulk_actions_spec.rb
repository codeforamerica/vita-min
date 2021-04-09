require "rails_helper"

RSpec.describe "Creating and reviewing bulk actions", active_job: true do
  let(:user) { create :admin_user }
  let!(:old_org) { create :organization, name: "Onion Organization" }
  let!(:new_org) { create :organization, name: "Orange Organization" }
  let!(:client_es) { create :client_with_intake_and_return, status: "prep_info_requested", vita_partner: old_org }
  let!(:client_en) { create :client_with_intake_and_return, status: "prep_info_requested", vita_partner: old_org }
  before do
    login_as user
    client_es.intake.update(preferred_name: "Nombre", locale: "es", email_notification_opt_in: "yes", email_address: "someone@example.com")
    client_en.intake.update(preferred_name: "Name", locale: "en", sms_notification_opt_in: "yes", sms_phone_number: "+15005550006")
  end

  scenario "bulk changing clients' organizations" do

    # creation process should be added, but until then, we'll create one for the tail end of the feature spec
    client_selection = create :client_selection, clients: [client_es, client_en]

    visit bulk_action_hub_client_selection_path(id: client_selection.id)
    click_on "Change organization"

    expect(page).to have_text "You’ve selected Change Organization for 2 clients"
    select "Orange Organization", from: "New organization"
    fill_in "Send message (English)", with: "Orange is your best bet"
    fill_in "Send message (Spanish)", with: "Naranja es la mejor"
    fill_in "Add an internal note", with: "Moved!"
    click_on "Submit"

    # check notifications here
    # expect(current_path).to eq hub_user_notifications_path

    # until notifications are ready, we will redirect back to the client selection
    expect(current_path).to eq hub_client_selection_path(id: client_selection.id)
    visit(hub_client_selection_path(id: client_selection))

    within "#client-#{client_es.id}" do
      expect(page).to have_text "Orange Organization"
      click_on "Nombre"
    end
    click_on "Notes"
    expect(page).to have_text "Moved!"

    perform_enqueued_jobs

    click_on "Messages"
    expect(page).to have_text "Naranja es la mejor"

    visit hub_client_selection_path(id: client_selection.id)
    within "#client-#{client_en.id}" do
      click_on "Name"
    end
    click_on "Notes"
    expect(page).to have_text "Moved!"
    click_on "Messages"
    expect(page).to have_text "Orange is your best bet"
  end
end
