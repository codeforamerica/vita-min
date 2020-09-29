require "rails_helper"

RSpec.feature "Read and send messages to a client" do
  context "As a beta tester" do
    let(:beta_tester) { create :beta_tester }
    let(:client) { create :client }
    before do
      login_as beta_tester
    end

    scenario "I can view a client's information and send them a message" do
      visit client_path(id: client)

      within(".client-header") do
        expect(page).to have_text client.preferred_name
        expect(page).to have_text client.id
      end

      within(".client-navigation") do
        expect(page).to have_css("a.tab-bar__tab.is-selected", text: "Client Profile")
        expect(page).to have_link("Messages")
        expect(page).to have_link("Documents")
        expect(page).to have_link("Notes")
      end

      click_on "Messages"
      expect(page).to have_css("a.tab-bar__tab.is-selected", text: "Messages")
      expect(page).to have_text("Send a text message")

      # TODO: fill out this spec more
    end
  end
end