require "rails_helper"

RSpec.feature "View and add internal notes for a client" do
  context "As an authenticated user" do
    let(:organization) { create :organization }
    let(:user) { create :user, timezone: "America/Los_Angeles", role: create(:organization_lead_role, organization: organization) }
    let(:documents) { create_list(:document, 3, created_at: DateTime.new(2020, 3, 1).utc, document_type: "Employment") }
    let(:client) { create :client, vita_partner: organization, intake: create(:intake, preferred_name: "Bart Simpson"), documents: documents }
    before do
      login_as user
    end

    scenario "view document list and change a display name" do
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
  end
end
