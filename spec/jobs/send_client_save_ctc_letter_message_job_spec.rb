require 'rails_helper'

RSpec.describe SendClientSaveCtcLetterMessageJob, type: :job do
  describe "#perform" do
    before do
      allow(ClientMessagingService).to receive(:send_system_email).and_call_original
      allow(ClientMessagingService).to receive(:send_system_text_message).and_call_original
      allow(ClientMessagingService).to receive(:send_email).and_call_original
    end

    around do |example|
      capture_output { example.run }
    end

    let(:sms_opt_in) { "yes" }
    let(:email_opt_in) { "yes" }
    let!(:intake) { create :archived_2021_ctc_intake, locale: "en", email_notification_opt_in: email_opt_in, sms_notification_opt_in: sms_opt_in, email_address: "example@example.com", sms_phone_number: "+14155551212" }

    context "a client has opted-in to email notification" do
      context "CTC client" do
        it "sends a message with CTC sign-off" do
          expect do
            described_class.perform_now(number_of_clients: 1)
          end.to change(OutgoingEmail, :count).by(1)

          expect(ClientMessagingService).to have_received(:send_system_email).with(
            client: intake.client,
            body: I18n.t('.messages.save_ctc_letter.email.body', service_name: "GetCTC", locale: :en),
            subject: I18n.t('messages.save_ctc_letter.email.subject', locale: :en),
            locale: "en",
            tax_return: nil
          )

          expect(ClientMessagingService).to have_received(:send_email)
        end
      end

      context "GYR client" do
        let!(:intake) { create :archived_2021_gyr_intake, locale: "en", email_notification_opt_in: email_opt_in, sms_notification_opt_in: sms_opt_in, type: 'Intake::GyrIntake' }

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

    context "when there are multiple clients that have opted into communication" do
      let!(:intake_1) { create :archived_2021_ctc_intake, locale: "en", email_notification_opt_in: "yes", email_address: "example@example.com" }
      let!(:intake_2) { create :archived_2021_ctc_intake, locale: "en", sms_notification_opt_in: "yes", sms_phone_number: "+14155551212" }
      let!(:intake_3) { create :archived_2021_ctc_intake, locale: "en", sms_notification_opt_in: "yes", sms_phone_number: "+14155551213" }

      it "sends messages to the number of clients specified" do
        described_class.perform_now(number_of_clients: 2)

        expect(ClientMessagingService).to have_received(:send_system_text_message).exactly(2)
        expect(ClientMessagingService).to have_received(:send_system_email).exactly(2)
      end
    end

    context "when client has already received a message" do
      before do
        described_class.perform_now(number_of_clients: 1)
      end

      it "does not send them another message" do
        expect do
          described_class.perform_now(number_of_clients: 1)
        end.to change(OutgoingEmail, :count).by(0)
      end
    end
  end
end
