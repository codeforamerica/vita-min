require "rails_helper"

RSpec.feature "Read and send messages to a client", js: true do
  context "As an authenticated user" do
    let(:user) { create :organization_lead_user }
    let(:intake) do
      build(
        :intake,
        preferred_name: "Tobias",
        email_address: "tfunke@example.com",
        email_notification_opt_in: "yes",
        phone_number: "+14155551212",
        sms_phone_number: "+14155551212",
        sms_notification_opt_in: "yes"
      )
    end
    let(:client) { create(:client, vita_partner: user.role.organization, intake: intake) }

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

    context "the client's intake has been archived" do
      let!(:incoming_text_message) { create :incoming_text_message, client: client, body: "it is me, a client", created_at: DateTime.now }
      let!(:outbound_call) { create :outbound_call, client: client, user: user }

      let(:intake) { nil }
      let!(:archived_intake) do
        create(
          :archived_2021_gyr_intake,
          client: client,
          preferred_name: "Tobias",
          email_address: "tfunke@example.com",
          email_notification_opt_in: "yes",
          phone_number: "+14155551212",
          sms_phone_number: "+14155551212",
          sms_notification_opt_in: "yes"
        )
      end

      it "still shows the client's information successfully" do
        visit hub_client_path(id: client)
        click_on "Messages"

        expect(page).to have_content(archived_intake.preferred_name)
        expect(page).to have_content(incoming_text_message.body)
        expect(page).to have_content("Called by")
      end
    end

    context "the last outgoing message is from the client" do
      let(:outgoing_text_message) { build :outgoing_text_message, client: client, created_at: DateTime.now - 1.hour }
      let!(:incoming_text_message) { create :incoming_text_message, client: client, body: "thank you! :)))))))))", created_at: DateTime.now }

      scenario "I can mark a client as response not needed" do
        visit hub_client_path(id: client)
        click_on "Messages"

        within(".client-container") do
          expect(client.first_unanswered_incoming_interaction_at).to be_present
          expect(page).to have_selector :link_or_button, 'Mark as "Response not needed"'
          click_on 'Mark as "Response not needed"'
          expect(page).not_to have_selector :link_or_button, 'Mark as "Response not needed"'
        end
      end
    end
  end
end
