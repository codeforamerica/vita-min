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
          email_notification_opt_in: "yes",
          phone_number: "+14155551212",
          sms_phone_number: "+14155551212",
          sms_notification_opt_in: "yes"
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

    context "the last outgoing message is from the client" do
      let(:outgoing_text_message) { build :outgoing_text_message, client: client, created_at: DateTime.now - 1.hour }
      let!(:incoming_text_message) { create :incoming_text_message, client: client, body: "thank you! :)))))))))", created_at: DateTime.now }

      scenario "I can mark a client as response not needed" do
        visit hub_client_path(id: client)
        click_on "Messages"

        within(".day-list") do
          expect(page).to have_text('Mark as "Response not needed"', count: 1)
          expect(client.first_unanswered_incoming_interaction_at).to be_present
          click_on 'Mark as "Response not needed"'
          expect(client.first_unanswered_incoming_interaction_at).not_to be_present
        end
      end
    end
  end
end
