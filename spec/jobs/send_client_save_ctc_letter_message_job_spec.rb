require 'rails_helper'

RSpec.describe SendClientSaveCtcLetterMessageJob, type: :job do
  describe "#perform" do
    before do
      allow(ClientMessagingService).to receive(:send_system_email)
      allow(ClientMessagingService).to receive(:send_system_text_message)
    end

    let(:sms_opt_in) { "yes" }
    let(:email_opt_in) { "yes" }
    let!(:intake) { create :archived_2021_intake, locale: "en", email_notification_opt_in: email_opt_in, sms_notification_opt_in: sms_opt_in }

    context "a client has opted-in to email notification" do
      before do
        allow(ClientMessagingService).to receive(:contact_methods).and_return({ email: "example@example.com" })
      end

      context "CTC client" do
        it "sends a message with CTC sign-off" do
          described_class.perform_now(number_of_clients: 1)

          expect(ClientMessagingService).to have_received(:send_system_email).with(
            client: intake.client,
            body: I18n.t('.messages.save_ctc_letter.email.body', service_name: "GetCTC", locale: :en),
            subject: I18n.t('messages.save_ctc_letter.email.subject', locale: :en),
            locale: "en",
            tax_return: nil
          )
        end
      end

      context "GYR client" do
        let!(:intake) { create :archived_2021_intake, locale: "en", email_notification_opt_in: email_opt_in, sms_notification_opt_in: sms_opt_in, type: 'Intake::GyrIntake' }

        it "sends a message with GYR sign-off" do
          described_class.perform_now(number_of_clients: 1)

          expect(ClientMessagingService).to have_received(:send_system_email).with(
            client: intake.client,
            body: I18n.t('.messages.save_ctc_letter.email.body', service_name: "GetYourRefund", locale: :en),
            subject: I18n.t('messages.save_ctc_letter.email.subject', locale: :en),
            locale: "en",
            tax_return: nil
          )
        end
      end
    end

    context "a client has opted-in to sms notification" do
      before do
        allow(ClientMessagingService).to receive(:contact_methods).and_return({ sms_phone_number: "+14155551212" })
      end

      it "sends a sms text" do
        described_class.perform_now(number_of_clients: 1)

        expect(ClientMessagingService).to have_received(:send_system_text_message).with(
          client: intake.client,
          body: I18n.t('messages.save_ctc_letter.sms', locale: :en),
          locale: "en",
          tax_return: nil
        )
      end
    end
  end
end