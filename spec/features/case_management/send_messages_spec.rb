require "rails_helper"

RSpec.feature "Read and send messages to a client", js: true do
  context "As a beta tester" do
    let(:beta_tester) { create :beta_tester }
    let(:client) { create :client }
    before do
      login_as beta_tester
    end

    scenario "I can view a client's information and send them a message" do
      visit case_management_client_path(id: client)

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

      within(".message-list") do
        expect(page).to have_text "Example text message"
      end
    end

    scenario "I can send an email with an attachment" do
      visit case_management_client_messages_path(client_id: client)

      within(".email-form") do
        fill_in "Send an email", with: "Example email"
        attach_file("outgoing_email[attachment]", "spec/fixtures/attachments/test-pattern.png")
        expect(page).to have_selector("div#attachment-custom-preview img")
        attach_file("outgoing_email[attachment]", "spec/fixtures/attachments/document_bundle.pdf")
        # Replaces custom file-streamed preview with default preview for non-image upload types.
        expect(page).not_to have_selector("div#attachment-custom-preview img")
        expect(page).to have_selector("img#attachment-image-preview-default")

        click_on "Send"
      end

      within(".message-list") do
        expect(page).to have_text "Example email"
        expect(page).to have_text "document_bundle.pdf"
      end
    end
  end
end