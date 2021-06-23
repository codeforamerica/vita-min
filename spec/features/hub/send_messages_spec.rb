require "rails_helper"

RSpec.feature "Read and send messages to a client", js: true do
  context "As an authenticated user" do
    let(:user) { create :organization_lead_user }
    let(:client) do
      create(
        :client,
        vita_partner: user.role.organization,
        intake: create(
          :intake,
          preferred_name: "Tobias",
          email_address: "tfunke@example.com",
          phone_number: "+14155551212",
          sms_phone_number: "+14155551212"
        )
      )
    end
    before do
      login_as user
    end

    scenario "I can view a client's information and send them a message" do
      visit hub_client_path(id: client)

      within(".client-header") do
        expect(page).to have_text "Tobias"
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

      within(".day-list") do
        expect(page).to have_text "Example text message"
      end
    end

    scenario "I can send an email with an attachment" do
      visit hub_client_messages_path(client_id: client)

      within(".email-form") do
        fill_in "Send an email", with: "Example email"
        attach_file("outgoing_email[attachment]", "spec/fixtures/files/test-pattern.png")
        expect(page.find('#attachment-image-preview')['src']).to have_content 'data:image/png'

        attach_file("outgoing_email[attachment]", "spec/fixtures/files/document_bundle.pdf")
        # Replaces custom file-streamed preview with default preview for non-image upload types.
        expect(page.find('#attachment-image-preview')['src']).to have_content '/assets/file-icon'
        click_on "Send"
      end

      within(".day-list") do
        expect(page).to have_text "Example email"
        expect(page).to have_text "document_bundle.pdf"
      end
    end
  end
end
