require "rails_helper"

RSpec.feature "View and add internal notes for a client" do
  context "As an authenticated user" do
    let(:user) { create :user_with_membership}
    let(:vita_partner) { user.memberships.first.vita_partner }
    let(:client) { create :client, vita_partner: vita_partner, intake: create(:intake, preferred_name: "Bart Simpson") }
    before do
      login_as user
    end

    scenario "view document list and change a display name" do
      visit case_management_client_notes_path(client_id: client.id)

      expect(page).to have_selector("h1", text: "Bart Simpson")
      fill_in "Add a note", with: "Some pertinent info, presumably"
      click_on "Save"

      new_note = Note.last
      expect(new_note.client).to eq client
      expect(new_note.user).to eq user
    end
  end
end