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

      context "when the email address is a match for an intake" do
        before do
          allow_any_instance_of(ClientLoginService).to receive(:can_login_by_sms_verification?).and_return true
        end

        it "requests a code from EmailVerificationCodeService" do
          described_class.perform_now(**params)
          expect(TextMessageVerificationCodeService).to have_received(:request_code).with(a_hash_including(
                                                                                        **params, service_type: service_type
                                                                                    ))
        end
      end

      context "when the email address is not a match for an intake" do
        before do
          allow_any_instance_of(ClientLoginService).to receive(:can_login_by_email_verification?).and_return false
        end

        let(:text_message_body_es) {
          <<~ESTEXT
          Alguien intentó ingresar a GetYourRefund con este número de teléfono, pero no encontramos el número en nuestro registro. ¿Usó otro número para registrarse?
          También puede ir a https://test.example.com/es para empezar su declaración.
          ESTEXT
        }

        let(:text_message_body_en) {
          <<~ENTEXT
          Someone tried to sign in to GetCTC with this phone number, but we couldn't find a match. Did you sign up with a different phone number?
          You can also visit https://ctc.test.example.com/en to get started.
          ENTEXT
        }

        context "locale es" do
          let(:locale) { "es" }
          let(:service_type) { :gyr }
          it "sends a no match text with spanish body" do
            described_class.perform_now(**params)
            expect(TextMessageVerificationCodeService).not_to have_received(:request_code)
            expect(TwilioService).to have_received(:send_text_message).with(a_hash_including(
                                                                                body: text_message_body_es,
                                                                                to: params[:phone_number]
                                                                            ))
          end
        end

        context "locale en" do
          let(:locale) { "en" }
          it "sends a no match text with english body" do

            described_class.perform_now(**params)
            expect(TextMessageVerificationCodeService).not_to have_received(:request_code)
            expect(TwilioService).to have_received(:send_text_message).with(a_hash_including(
                                                                                body: text_message_body_en,
                                                                                to: params[:phone_number]
                                                                            ))
          end
        end
      end
    end
  end
end