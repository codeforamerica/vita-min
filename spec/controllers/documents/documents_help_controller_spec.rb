require "rails_helper"

RSpec.describe Documents::DocumentsHelpController, type: :controller do
  describe "#send_reminder" do
    let!(:client) { create(:intake, email_address: "gork@example.com", sms_phone_number: "+14155537865", email_notification_opt_in: "yes", sms_notification_opt_in: "yes", preferred_name: "Gilly").client }
    let(:params) do
      { next_path: "/en/documents/selfies",
        doc_type: "DocumentTypes::Identity" }
    end

    before do
      allow(ClientMessagingService).to receive(:send_system_message_to_all_opted_in_contact_methods)
      sign_in client
    end

    it "sends a message with the reminder link in the preferred contact method" do
      post :send_reminder, params: params

      sms_body = <<~SMS
        Hello Gilly,
        We received your request for a reminder. Please send us ID with this http://test.host/en/portal/login.
        Your tax team at GetYourRefund
      SMS

      email_body = <<~EMAIL
        Hello Gilly,
        We received your request for a reminder. Please send us ID with this <a href="http://test.host/en/portal/login">link</a>.
        Your tax team at GetYourRefund
      EMAIL

      expect(ClientMessagingService).to have_received(:send_system_message_to_all_opted_in_contact_methods).with(
        client,
        email_body: email_body,
        sms_body: sms_body,
        subject: "Reminder to upload ID on GetYourRefund"
      )
    end

    it "redirects to next path and flashes an notice" do
      post :send_reminder, params: params
      expect(response).to redirect_to("/en/documents/selfies")
      expect(flash.now[:notice]).to eq "Great! We just sent you a reminder link."
    end
  end

  # Controller action for needs_doc_help
  # status change: Change status,
  # create system note,
  # and maybe needs response change,
  # maybe notification. AND flash message.
  describe "#request_doc_help" do
    let!(:client) { create :client }
    let(:params) do
      { next_path: "/en/documents/selfies",
        doc_type: "DocumentTypes::Identity" }
    end

    before do
      sign_in client
    end

    context "client needs help finding document" do
      it "flashes a notice and redirects to next path" do
        post :find_doc_help, params: params
        expect(response).to redirect_to("/en/documents/selfies")
        expect(flash.now[:notice]).to eq "Thank you! We updated your tax specialist."
      end

      # it "changes the status" do
      #
      # end
      #
      # it "creates a system note and notification" do
      #
      # end
      #
      # it "changes need response" do
      #
      # end
    end
  end
end