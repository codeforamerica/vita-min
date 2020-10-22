require "rails_helper"

RSpec.feature "View and add internal notes for a client" do
  context "As a beta tester" do
    let(:vita_partner) { create :vita_partner }
    let(:beta_tester) { create :beta_tester, vita_partner: vita_partner }
    let(:client) { create :client, preferred_name: "Bart Simpson", vita_partner: vita_partner }
    before do
      login_as beta_tester
    end

    scenario "view document list and change a display name" do
      visit case_management_client_notes_path(client_id: client.id)

      expect(page).to have_selector("h1", text: "Bart Simpson")
      fill_in "Add a note", with: "Some pertinent info, presumably"
      click_on "Save"

      new_note = Note.last
      expect(new_note.client).to eq client
      expect(new_note.user).to eq beta_tester
    end
  end
end