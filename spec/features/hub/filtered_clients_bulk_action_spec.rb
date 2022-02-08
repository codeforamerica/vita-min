require "rails_helper"

RSpec.describe "Filtering clients for bulk actions", active_job: true do
  let!(:user) { create :admin_user }
  let(:selected_org) { create :organization, name: "Orange Organization" }
  let(:unselected_org) { create :organization, name: "Rooster Brew" }
  let!(:all_selected_clients) { create_list :client_with_intake_and_return, 30, vita_partner: selected_org }
  let!(:unselected_client) { create :client_with_intake_and_return, state: "intake_reviewing", vita_partner: unselected_org }

  before do
    create :tax_return, client: Client.where(vita_partner: selected_org).first, year: 2019
  end

  scenario "take action on all filtered clients", js: true do
    login_as user

    visit hub_clients_path

    fill_in_tagify '.multi-select-vita-partner', "Orange Organization"
    click_on "Filter results"

    find("#bulk-edit-select-all").click
    expect(page).to have_text "Displaying clients 1 - 25 of 30"
    click_on "Take action on all 31 returns"

    expect(page).to have_text "Choose your bulk action"

    click_on "Change organization"

    expect(page).to have_text "You’ve selected Change Organization for 30 clients"
    select "Rooster Brew", from: "New organization"

    click_on "Submit"

    expect(page).to have_text "Successful Bulk Client Organization Update"
    expect(page).to have_text "You successfully moved 30 clients to Rooster Brew."
  end
end
