require 'rails_helper'

RSpec.describe SendClientSaveCtcLetterMessageJob, type: :job do
  describe "#perform" do
    before do
      allow(ClientMessagingService).to receive(:send_system_email)
      allow(ClientMessagingService).to receive(:send_system_text_message)
    end

    let(:client) { create(:ctc_intake, locale: "es", email_notification_opt_in: "yes", sms_notification_opt_in: "no").client }
    let!(:tax_return) { create :tax_return, client: client, year: TaxReturn.current_tax_year }

    context "a client has opted-in to email notification" do
      before do
        allow(ClientMessagingService).to receive(:contact_methods).and_return({ email: "example@example.com" })
      end

      context "CTC client" do
        it "sends a message with CTC sign-off" do
          described_class.perform_now(client)

          expect(ClientMessagingService).to have_received(:send_system_email).with(
            client: client,
            body: I18n.t('.messages.save_ctc_letter.email.body', service_name: "GetCTC", locale: :es),
            subject: I18n.t('messages.save_ctc_letter.email.subject', locale: :es),
            locale: "es",
            tax_return: nil
          )
        end
      end

      context "GYR client" do
        let(:client) { create(:intake, locale: "en", email_notification_opt_in: "yes").client }

        it "sends a message with GYR sign-off" do
          described_class.perform_now(client)

          expect(ClientMessagingService).to have_received(:send_system_email).with(
            client: client,
            body: I18n.t('.messages.save_ctc_letter.email.body', service_name: "GetYourRefund", locale: :en),
            subject: I18n.t('messages.save_ctc_letter.email.subject', locale: :en),
            locale: "en",
            tax_return: nil
          )
        end
      end
    end

    context "a client has opted-in to sms notification" do
      let!(:client) { create(:ctc_intake, locale: "en", email_notification_opt_in: "no", sms_notification_opt_in: "yes", email_address: nil).client }

      before do
        allow(ClientMessagingService).to receive(:contact_methods).and_return({ sms_phone_number: "+14155551212" })
      end

      it "sends a sms text" do
        described_class.perform_now(client)

        expect(ClientMessagingService).to have_received(:send_system_text_message).with(
          client: client,
          body: I18n.t('messages.save_ctc_letter.sms', locale: :en),
          locale: "en",
          tax_return: nil
        )
      end
    end
  end
end