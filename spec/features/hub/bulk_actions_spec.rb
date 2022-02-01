require "rails_helper"

RSpec.describe "Selecting clients for bulk actions", active_job: true do
  let(:user) { create :admin_user, name: "Admin the First" }
  let!(:new_user) { create :admin_user, name: "Admin the Second", role: create(:organization_lead_role, organization: old_org)}
  let!(:old_org) { create :organization, name: "Onion Organization" }
  let!(:new_org) { create :organization, name: "Orange Organization" }
  let!(:client_es) { create :client_with_intake_and_return, state: "prep_info_requested", vita_partner: old_org }
  let!(:client_en) { create :client_with_intake_and_return, state: "intake_reviewing", vita_partner: old_org }
  before do
    login_as user
    client_es.intake.update(preferred_name: "Nombre", locale: "es", email_notification_opt_in: "yes", email_address: "someone@example.com")
    client_en.intake.update(preferred_name: "Name", locale: "en", sms_notification_opt_in: "yes", sms_phone_number: "+15005550006")
  end

  scenario "bulk changing clients' organizations", js: true do
    visit hub_clients_path

    expect(page).not_to have_text "Take action"
    within "#client-#{client_en.id}" do
      check "tr_ids_#{client_en.tax_returns.first.id}"
    end
    within "#client-#{client_es.id}" do
      check "tr_ids_#{client_es.tax_returns.first.id}"
    end
    click_on "Take action"

    click_on "Change organization"

    expect(page).to have_text "You’ve selected Change Organization for 2 clients"
    select "Orange Organization", from: "New organization"
    fill_in "Send message (English)", with: "Orange is your best bet"
    fill_in "Send message (Spanish)", with: "Naranja es la mejor"
    fill_in "Add an internal note", with: "Moved!"
    click_on "Submit"

    expect(current_path).to eq hub_user_notifications_path
    expect(page).to have_text "You successfully moved 2 clients to Orange Organization."
    expect(page).to have_text "You successfully added internal notes to 2 clients."
    expect(page).to have_text "Bulk Send a Message In Progress"
    expect(page).to have_text "We are still contacting 2 clients."

    within ".in-progress" do
      click_on "2 clients"
    end

    within "#client-#{client_es.id}" do
      expect(page).to have_text "Orange Organization"
      click_on "Nombre"
    end
    click_on "Notes"
    expect(page).to have_text "Moved!"

    perform_enqueued_jobs

    click_on "Messages"
    expect(page).to have_text "Naranja es la mejor"

    visit hub_user_notifications_path
    within ".in-progress" do
      click_on "2 clients"
    end

    within "#client-#{client_en.id}" do
      click_on "Name"
    end
    click_on "Notes"
    expect(page).to have_text "Moved!"
    click_on "Messages"
    expect(page).to have_text "Orange is your best bet"
  end

  scenario "bulk sending a message", js: true do
    visit hub_clients_path

    expect(page).not_to have_text "Take action"
    within "#client-#{client_en.id}" do
      check "tr_ids_#{client_en.tax_returns.first.id}"
    end
    within "#client-#{client_es.id}" do
      check "tr_ids_#{client_es.tax_returns.first.id}"
    end
    click_on "Take action"

    click_on "Send a message"

    expect(page).to have_text "You’ve selected Send a Message for 2 clients"
    fill_in "Send message (English)", with: "Orange is your best bet"
    fill_in "Send message (Spanish)", with: "Naranja es la mejor"
    click_on "Submit"

    expect(current_path).to eq hub_user_notifications_path
    expect(page).to have_text "Bulk Send a Message In Progress"
    expect(page).to have_text "We are still contacting 2 clients."

    perform_enqueued_jobs

    within ".in-progress" do
      click_on "2 clients"
    end
    within "#client-#{client_es.id}" do
      click_on "Nombre"
    end
    click_on "Messages"
    expect(page).to have_text "Naranja es la mejor"

    visit hub_user_notifications_path
    within ".in-progress" do
      click_on "2 clients"
    end

    within "#client-#{client_en.id}" do
      click_on "Name"
    end
    click_on "Messages"
    expect(page).to have_text "Orange is your best bet"
  end

  scenario "bulk changing assignee and/or status", js: true do
    visit hub_clients_path

    expect(page).not_to have_text "Take action"
    within "#client-#{client_en.id}" do
      check "tr_ids_#{client_en.tax_returns.first.id}"
    end
    within "#client-#{client_es.id}" do
      check "tr_ids_#{client_es.tax_returns.first.id}"
    end
    click_on "Take action"

    click_on "Change assignee and/or status"
    expect(page).to have_text "You’ve selected Change Assignee and/or Status for 2 returns with the following statuses:"
    expect(page).to have_text "Info requested, Reviewing."

    expect(page).to have_text "Keep current assignee"
    expect(page).to have_text "Keep current status"

    select new_user.name, from: "New Assignee"
    select "Greeter - info requested", from: "New Status"
    expect(page).to have_text new_user.name

    # Messages should be autofilled by templates due to status update
    expect(page).to have_text "Hello"
    expect(page).to have_text "Hola"

    click_on "Submit"

    expect(current_path).to eq hub_user_notifications_path

    expect(page).to have_text "You successfully assigned 2 tax returns to Admin the Second."
    expect(page).to have_text "You successfully updated 2 tax returns to Greeter - info requested."
    expect(page).to have_text "Bulk Send a Message In Progress"
    expect(page).to have_text "We are still contacting 2 clients."
  end
end
