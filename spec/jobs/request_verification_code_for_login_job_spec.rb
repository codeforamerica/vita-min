require "rails_helper"

describe RequestVerificationCodeForLoginJob do
  describe "perform" do
    context "with an email address" do
      let(:params) do
        {
            email_address: "client@example.com",
            visitor_id: "87h2897gh2",
            locale: "es",
            service_type: :gyr
        }
      end
      let(:mailer_double) { double }
      before do
        allow(EmailVerificationCodeService).to receive(:request_code)
        allow(VerificationCodeMailer).to receive(:no_match_found).and_return mailer_double
        allow(mailer_double).to receive(:deliver_now)
      end

      context "when the email address is a match for an intake" do
        before do
          allow_any_instance_of(ClientLoginService).to receive(:can_login_by_email_verification?).and_return true

        end

        it "requests a code from EmailVerificationCodeService" do
          described_class.perform_now(**params)
          expect(EmailVerificationCodeService).to have_received(:request_code).with(a_hash_including(
                                                                                      **params, service_type: :gyr
                                                                                    ))
        end
      end

      context "when the email address is not a match for an intake" do
        before do
          allow_any_instance_of(ClientLoginService).to receive(:can_login_by_email_verification?).and_return false
        end

        it "sends a no match email" do
          described_class.perform_now(**params)
          expect(EmailVerificationCodeService).not_to have_received(:request_code)
          expect(VerificationCodeMailer).to have_received(:no_match_found)
          expect(mailer_double).to have_received(:deliver_now)
        end
      end
    end

    context "with a phone number" do
      let(:locale) { "en" }
      let(:service_type) { :ctc }
      let(:params) do
        {
          phone_number: "+15125551234",
          visitor_id: "87h2897gh2",
          locale: locale,
          service_type: service_type
        }
      end

      before do
        allow(TextMessageVerificationCodeService).to receive(:request_code)
        allow(TwilioService).to receive(:send_text_message)
      end

      context "when the phone number is a match for an intake" do
        before do
          allow_any_instance_of(ClientLoginService).to receive(:can_login_by_sms_verification?).and_return true
        end

        it "requests a code from TextMessageVerificationCodeService" do
          described_class.perform_now(**params)
          expect(TextMessageVerificationCodeService).to have_received(:request_code).with(a_hash_including(
                                                                                        **params, service_type: service_type
                                                                                    ))
        end
      end

      context "when the phone number is not a match for an intake" do
        before do
          allow_any_instance_of(ClientLoginService).to receive(:can_login_by_sms_verification?).and_return false
        end

        let(:ctc_text_message_body_es) { I18n.t("verification_code_sms.no_match_ctc", url: "https://ctc.test.example.com/es", locale: :es) }

        let(:ctc_text_message_body_en) { I18n.t("verification_code_sms.no_match_ctc", url: "https://ctc.test.example.com/en", locale: :en) }

        let(:gyr_text_message_body_es) { I18n.t("verification_code_sms.no_match_gyr", url: "https://test.example.com/es", locale: :es) }

        let(:gyr_text_message_body_en) { I18n.t("verification_code_sms.no_match_gyr", url: "https://test.example.com/en", locale: :en) }

        context "locale es and service type is gyr" do
          let(:locale) { "es" }
          let(:service_type) { :gyr }
          it "sends a no match text with spanish body" do
            described_class.perform_now(**params)
            expect(TextMessageVerificationCodeService).not_to have_received(:request_code)
            expect(TwilioService).to have_received(:send_text_message)
                                       .with(a_hash_including(
                                               body: gyr_text_message_body_es,
                                               to: params[:phone_number]
                                             ))
          end
        end

        context "locale en and service type is gyr" do
          let(:locale) { "en" }
          let(:service_type) { :gyr }
          it "sends a no match text with english body" do
            described_class.perform_now(**params)
            expect(TextMessageVerificationCodeService).not_to have_received(:request_code)
            expect(TwilioService).to have_received(:send_text_message)
                                       .with(a_hash_including(
                                               body: gyr_text_message_body_en,
                                               to: params[:phone_number]
                                             ))
          end
        end

        context "locale es and service type is ctc" do
          let(:locale) { "es" }
          let(:service_type) { :ctc }
          it "sends a no match text with spanish body" do
            described_class.perform_now(**params)
            expect(TextMessageVerificationCodeService).not_to have_received(:request_code)
            expect(TwilioService).to have_received(:send_text_message)
                                       .with(a_hash_including(
                                               body: ctc_text_message_body_es,
                                               to: params[:phone_number]
                                             ))
          end
        end

        context "locale en and service type is ctc" do
          let(:locale) { "en" }
          let(:service_type) { :ctc }
          it "sends a no match text with english body" do
            described_class.perform_now(**params)
            expect(TextMessageVerificationCodeService).not_to have_received(:request_code)
            expect(TwilioService).to have_received(:send_text_message)
                                       .with(a_hash_including(
                                               body: ctc_text_message_body_en,
                                               to: params[:phone_number]
                                             ))
          end
        end
      end
    end
  end
end