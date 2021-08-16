require "rails_helper"

RSpec.feature "a client can send a message when logged into the portal" do
  context "sending a message" do
    let(:client) { create :client, vita_partner: (create :organization, name: "Koala Company"), intake: (create :intake, preferred_name: "Katie", email_notification_opt_in: "yes", email_address: "exampleemail@example.com", sms_phone_number: "+18324658840", sms_notification_opt_in: "yes") }
    before do
      login_as client, scope: :client
      allow(IntercomService).to receive(:create_intercom_message_from_portal_message)
    end

    scenario "linking to next step" do
      visit portal_root_path
      expect(page).to have_text "Welcome back Katie!"
      click_on "Message my tax specialist"
      expect(page).to have_selector "h1", text: "Message Koala Company"
      fill_in "What's on your mind?", with: "I have some questions about my tax return."
      click_on "Send message"
      expect(page).to have_text "Message sent! Responses will be sent by email/text to exampleemail@example.com or +18324658840."
    end
  end
end