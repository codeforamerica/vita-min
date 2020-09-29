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

      within(".text-message-form") do
        fill_in "Send a text message", with: "Example text message"
        click_on "Send"
      end

      within(".contact-history") do
        expect(page).to have_text "Example text message"
      end
    end
  end
end