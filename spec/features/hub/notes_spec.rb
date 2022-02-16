require "rails_helper"

RSpec.feature "View and add internal notes for a client" do
  context "As an authenticated user" do
    let(:organization) { create :organization }
    let(:user) { create :user, timezone: "America/Los_Angeles", role: create(:organization_lead_role, organization: organization) }
    let!(:documents) { create_list(:document, 3, created_at: DateTime.new(2020, 3, 1).utc, document_type: "Employment", uploaded_by: client, client: client) }
    let!(:not_included_docs) { create_list(:document, 2, created_at: DateTime.new(2020, 3,1).utc, uploaded_by: user, client: client) }
    let(:client) { create :client, vita_partner: organization, intake: create(:intake, preferred_name: "Bart Simpson") }
    before do
      login_as user
    end

    scenario "add an internal note to a client" do
      visit hub_client_notes_path(client_id: client.id)

      expect(page).to have_selector("h1", text: "Bart Simpson")
      expect(page).to have_text("4:00 PM") # 4:00 PM Pacific is midnight UTC; the note is created at midnight UTC
      expect(page).to have_text("Client added 3 documents.")
      fill_in "Add a note", with: "Some pertinent info, presumably"
      click_on "Save"

      new_note = Note.last
      expect(new_note.client).to eq client
      expect(new_note.user).to eq user
    end

    scenario "tagging a user", :js do
      visit hub_client_notes_path(client_id: client.id)
      expect(page).not_to have_css(".tagify__dropdown")
      input = find('span.tagify__input')
      input.click
      input.send_keys("@")
      expect(page).to have_css(".tagify__dropdown")
      option = find("div.tagify__dropdown__wrapper div")
      expect(option).to have_text user.name_with_role_and_entity
      option.click
      expect(input).to have_text user.name_with_role
      click_on "Save"

      note = find(".note#last-item")
      expect(note).to have_text "@#{user.name_with_role}"
    end
  end
end