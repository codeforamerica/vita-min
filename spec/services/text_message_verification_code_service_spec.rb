require "rails_helper"

describe TextMessageVerificationCodeService do
  let(:phone_number) { "+18324651680" }
  let(:locale) { "en" }
  let(:visitor_id) { "visitor_id_1" }
  let(:client_id) { nil }
  let(:params) do
    {
        phone_number: phone_number,
        locale: locale,
        visitor_id: visitor_id,
        verification_type: verification_type
    }
  end
  describe "initialization" do
    context "verification_type" do
      let(:verification_type) { :unsupported }
      it "raises an error if verification_type is not in the list" do
        expect {
          described_class.new(**params)
        }.to raise_error ArgumentError, "Unsupported verification type: unsupported"
      end
    end
  end

  describe ".request_code" do
    let(:twilio_double) { double TwilioService }
    let(:access_token_double) { double TextMessageAccessToken }
    before do
      allow(TextMessageAccessToken).to receive(:create!).and_return access_token_double
      allow(TwilioService).to receive(:send_text_message).and_return twilio_double
      allow(VerificationTextMessage).to receive(:create!)
      allow(twilio_double).to receive(:sid).and_return "twilio_sid"
      allow(VerificationCodeService).to receive(:generate).and_return ["123456", "hashed_verification_code"]
      allow_any_instance_of(Mail::Message).to receive(:message_id).and_return("mocked_mailer_id")
      allow(DatadogApi).to receive(:increment)
    end

    context "when verification_type is ctc_intake" do
      let(:verification_type) { :ctc_intake }

      it "creates a VerificationTextMessage, sends an email, and creates an EmailAccessToken object" do
        described_class.request_code(**params)
        text_body = "Your 6-digit GetCTC verification code is: 123456. This code will expire after two days."

        expect(TwilioService).to have_received(:send_text_message).with(a_hash_including(
                                                                        to: phone_number,
                                                                        body: text_body
                                                                    ))
        # expect(email.body.encoded).to include "Your 6-digit GetCTC verification code is: 123456"
        expect(TextMessageAccessToken).to have_received(:create!).with(a_hash_including(
                                                                     sms_phone_number: phone_number,
                                                                     client_id: nil,
                                                                     token_type: "verification_code",
                                                                     token: Devise.token_generator.digest(TextMessageAccessToken, :token, "hashed_verification_code")
                                                                 ))
        expect(VerificationTextMessage).to have_received(:create!).with(a_hash_including(
                                                                      visitor_id: visitor_id,
                                                                      text_message_access_token: access_token_double,
                                                                      twilio_sid: "twilio_sid"
                                                                  ))
        expect(DatadogApi).to have_received(:increment).with "client_logins.verification_codes.text_message.created"
      end
    end

    context "when verification type is :gyr_intake" do
      let(:matching_intakes) { double }
      let(:verification_type) { :gyr_login }
      context "when there are accessible clients by phone number" do
        before do
          allow(ClientLoginService).to receive(:accessible_intakes).and_return(matching_intakes)
          allow(matching_intakes).to receive(:where).and_return(matching_intakes)
          allow(matching_intakes).to receive(:or).and_return(matching_intakes)
          allow(matching_intakes).to receive(:exists?).and_return(true)
        end

        it "creates a VerificationTextMessage, sends a text message, and creates an TextMessageAccessToken object" do
          described_class.request_code(**params)
          text_body = "Your 6-digit GetYourRefund verification code is: 123456. This code will expire after two days."

          expect(TwilioService).to have_received(:send_text_message).with(a_hash_including(
                                                                              to: phone_number,
                                                                              body: text_body
                                                                          ))
          expect(TextMessageAccessToken).to have_received(:create!).with(a_hash_including(
                                                                             sms_phone_number: phone_number,
                                                                             client_id: nil,
                                                                             token_type: "verification_code",
                                                                             token: Devise.token_generator.digest(TextMessageAccessToken, :token, "hashed_verification_code")
                                                                         ))
          expect(VerificationTextMessage).to have_received(:create!).with(a_hash_including(
                                                                              visitor_id: visitor_id,
                                                                              text_message_access_token: access_token_double,
                                                                              ))
          expect(DatadogApi).to have_received(:increment).with "client_logins.verification_codes.text_message.created"
        end
      end

      context "when the client phone number is not found" do
        let(:locale) { "es" }
        before do
          allow(ClientLoginService).to receive(:accessible_intakes).and_return(matching_intakes)
          allow(matching_intakes).to receive(:where).and_return(matching_intakes)
          allow(matching_intakes).to receive(:or).and_return(matching_intakes)
          allow(matching_intakes).to receive(:exists?).and_return(false)
        end
        it "sends the no match text and does not create accompanying objects" do
          text_message_body = <<~TEXT
          Alguien intentó ingresar a GetYourRefund con este número de teléfono, pero no encontramos el número en nuestro registro. ¿Usó otro número para registrarse?
          También puede ir a http://test.host/es y seleccione “Empiece ahora” para empezar su declaración.
          TEXT
          described_class.request_code(**params)
          expect(TwilioService).to have_received(:send_text_message).with(a_hash_including(
                                                                              to: phone_number,
                                                                              body: text_message_body
                                                                          )
          )
          expect(VerificationTextMessage).not_to have_received(:create!)
          expect(TextMessageAccessToken).not_to have_received(:create!)
          expect(DatadogApi).not_to have_received(:increment)
        end
      end
    end
  end
end