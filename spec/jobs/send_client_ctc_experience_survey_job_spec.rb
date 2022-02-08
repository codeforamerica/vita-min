require 'rails_helper'

RSpec.describe SendClientCtcExperienceSurveyJob, type: :job do
  describe "#perform" do
    before do
      allow(ClientMessagingService).to receive(:send_system_email)
      allow(ClientMessagingService).to receive(:send_system_text_message)
    end

    let(:client) { create(:ctc_intake, locale: "es").client }
    let!(:tax_return) { create :tax_return, client: client, year: TaxReturn.current_tax_year }

    context "sending the survey" do
      context "with a client who is opted-in to email notifications" do
        before do
          allow(ClientMessagingService).to receive(:contact_methods).and_return({email: "example@example.com"})
        end

        context "when the client has not received this survey" do
          it "sends it by email" do
            described_class.perform_now(client)

            expect(ClientMessagingService).to have_received(:send_system_email).with(
              client: client,
              body: a_string_including("qualtrics.com/jfe/form/SV_cHN2H3IWcxAEKPA"),
              subject: I18n.t('messages.surveys.ctc_experience.email.subject', locale: :es),
              locale: "es"
            )
            expect(client.reload.ctc_experience_survey_sent_at).to be_present
          end
        end
      end

      context "with a client who is opted-in to sms notifications" do
        let(:client) { create(:ctc_intake, locale: "es").client }
        before do
          allow(ClientMessagingService).to receive(:contact_methods).and_return({sms_phone_number: "+14155551212"})
        end

        context "when the client has not received this survey" do
          it "sends it by text" do
            described_class.perform_now(client)

            expect(ClientMessagingService).to have_received(:send_system_text_message).with(
              client: client,
              body: a_string_including("qualtrics.com/jfe/form/SV_cHN2H3IWcxAEKPA"),
              locale: "es"
            )
            expect(ClientMessagingService).not_to have_received(:send_system_email)
            expect(client.reload.ctc_experience_survey_sent_at).to be_present
          end
        end
      end

      context "with a client who is opted-in to email and sms notifications" do
        before do
          allow(ClientMessagingService).to receive(:contact_methods).and_return({ email: "example@example.com", sms_phone_number: "+14155551212" })
        end

        context "when the client has not received this survey" do
          it "sends it by email" do
            described_class.perform_now(client)

            expect(ClientMessagingService).to have_received(:send_system_email).with(
              client: client,
              body: a_string_including("qualtrics.com/jfe/form/SV_cHN2H3IWcxAEKPA"),
              subject: I18n.t('messages.surveys.ctc_experience.email.subject', locale: :es),
              locale: "es"
            )
            expect(ClientMessagingService).not_to have_received(:send_system_text_message)
            expect(client.reload.ctc_experience_survey_sent_at).to be_present
          end

          it "assigns a random variant for expGroup" do
            described_class.perform_now(client)

            expect(ClientMessagingService).to have_received(:send_system_email).with(
              client: client,
              body: a_string_matching(/expGroup=[123]/),
              subject: I18n.t('messages.surveys.ctc_experience.email.subject', locale: :es),
              locale: "es"
            )
          end
        end
      end

      context "with a client whose efile submission was accepted" do
        before do
          allow(ClientMessagingService).to receive(:contact_methods).and_return({email: "example@example.com", sms_phone_number: "+14155551212"})
        end

        it "includes something in the URL saying it was not rejected" do
          described_class.perform_now(client)

          expect(ClientMessagingService).to have_received(:send_system_email).with(
              client: client,
              body: a_string_including("ctcRejected=FALSE"),
              subject: I18n.t('messages.surveys.ctc_experience.email.subject', locale: :es),
              locale: "es"
          )
          expect(client.reload.ctc_experience_survey_sent_at).to be_present
        end
      end

      context "with a client whose efile submission was rejected" do
        let!(:tax_return) { create :tax_return, :file_rejected, client: client, year: TaxReturn.current_tax_year }

        before do
          allow(ClientMessagingService).to receive(:contact_methods).and_return({email: "example@example.com", sms_phone_number: "+14155551212"})
        end

        it "includes something in the URL saying it was accepted" do
          described_class.perform_now(client)

          expect(ClientMessagingService).to have_received(:send_system_email).with(
              client: client,
              body: a_string_including("ctcRejected=TRUE"),
              subject: I18n.t('messages.surveys.ctc_experience.email.subject', locale: :es),
              locale: "es"
          )
          expect(client.reload.ctc_experience_survey_sent_at).to be_present
        end
      end
    end

    context "not sending the survey" do
      context "with a client who has already received this survey with contact methods available" do
        before do
          allow(ClientMessagingService).to receive(:contact_methods).and_return({email: "example@example.com"})
          client.update(ctc_experience_survey_sent_at: DateTime.new(2021, 1, 1))
        end

        it "does not send it" do
          expect {
            described_class.perform_now(client)
          }.not_to change { client.reload.ctc_experience_survey_sent_at }

          expect(ClientMessagingService).not_to have_received(:send_system_email)
          expect(ClientMessagingService).not_to have_received(:send_system_text_message)
        end
      end

      context "with a client with no contact methods available" do
        before do
          allow(ClientMessagingService).to receive(:contact_methods).and_return({})
        end

        it "does not send it" do
          expect {
            described_class.perform_now(client)
          }.not_to change { client.reload.ctc_experience_survey_sent_at }

          expect(ClientMessagingService).not_to have_received(:send_system_email)
        end
      end
    end
  end
end
