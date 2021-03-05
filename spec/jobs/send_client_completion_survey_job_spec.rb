require 'rails_helper'

RSpec.describe SendClientCompletionSurveyJob, type: :job do
  describe "#perform" do
    context "with a client who is opted-in to email notifications" do
      let(:client) { create(:intake, email_address: "client@example.com", email_notification_opt_in: "yes", locale: "es").client }
      context "when the client has not received this survey" do
        before do
          allow(ClientMessagingService).to receive(:send_system_email)
        end

        it "sends it" do
          described_class.perform_now(client)

          expect(ClientMessagingService).to have_received(:send_system_email).with(
            client,
            a_string_including("qualtrics.com"),
            "¡Gracias por declarar tus impuestos con GetYourRefund!"
          )
        end
      end

      context "when the client has already received this survey" do
        before do

        end
      end
    end
  end
end

