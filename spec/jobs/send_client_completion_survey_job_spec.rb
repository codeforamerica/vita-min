require 'rails_helper'

RSpec.describe SendClientCompletionSurveyJob, type: :job do
  describe "#perform" do
    before do
      allow(ClientMessagingService).to receive(:send_system_email)
      allow(ClientMessagingService).to receive(:send_system_text_message)
    end

    let(:client) { create(:intake, locale: "es").client }

    context "sending the survey" do
      context "with a client who is opted-in to email notifications" do
        before do
          allow(ClientMessagingService).to receive(:contact_methods).and_return({email: "example@example.com"})
        end

        context "when the client has not received this survey" do
          it "sends it by email" do
            described_class.perform_now(client)

            expect(ClientMessagingService).to have_received(:send_system_email).with(
              client,
              a_string_including("qualtrics.com"),
              "¡Gracias por declarar tus impuestos con GetYourRefund!"
            )
            expect(client.reload.completion_survey_sent_at).to be_present
          end
        end
      end

      context "with a client who is opted-in to sms notifications" do
        let(:client) { create(:intake, locale: "es").client }
        before do
          allow(ClientMessagingService).to receive(:contact_methods).and_return({sms_phone_number: "+14155551212"})
        end

        context "when the client has not received this survey" do
          it "sends it by text" do
            described_class.perform_now(client)

            expect(ClientMessagingService).to have_received(:send_system_text_message).with(
              client,
              a_string_including("qualtrics.com"),
            )
            expect(ClientMessagingService).not_to have_received(:send_system_email)
            expect(client.reload.completion_survey_sent_at).to be_present
          end
        end
      end
    end

    context "not sending the survey" do
      context "with a client who has already received this survey with contact methods available" do
        before do
          allow(ClientMessagingService).to receive(:contact_methods).and_return({email: "example@example.com"})
          client.update(completion_survey_sent_at: DateTime.new(2021, 1, 1))
        end

        it "does not send it" do
          expect {
            described_class.perform_now(client)
          }.not_to change { client.reload.completion_survey_sent_at }

          expect(ClientMessagingService).not_to have_received(:send_system_email)
        end
      end

      context "with a client with no contact methods available" do
        before do
          allow(ClientMessagingService).to receive(:contact_methods).and_return({})
        end

        it "does not send it" do
          expect {
            described_class.perform_now(client)
          }.not_to change { client.reload.completion_survey_sent_at }

          expect(ClientMessagingService).not_to have_received(:send_system_email)
        end
      end
    end
  end
end
