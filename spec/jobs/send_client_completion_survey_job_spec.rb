require 'rails_helper'

RSpec.describe SendClientCompletionSurveyJob, type: :job do
  describe "#perform" do
    before do
      allow(ClientMessagingService).to receive(:send_system_email)
    end

    context "with a client who is opted-in to email notifications" do
      let(:client) { create(:intake, email_address: "client@example.com", email_notification_opt_in: "yes", locale: "es").client }
      context "when the client has not received this survey" do

        it "sends it" do
          described_class.perform_now(client)

          expect(ClientMessagingService).to have_received(:send_system_email).with(
            client,
            a_string_including("qualtrics.com"),
            "¡Gracias por declarar tus impuestos con GetYourRefund!"
          )
          expect(client.reload.completion_survey_sent_at).to be_present
        end
      end

      context "when the client has already received this survey" do
        before do
          client.update(completion_survey_sent_at: DateTime.new(2021, 1, 1))
        end

        it "does not send it" do
          described_class.perform_now(client)

          expect(ClientMessagingService).not_to have_received(:send_system_email)
        end
      end
    end
  end
end

