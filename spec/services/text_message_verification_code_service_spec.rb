require "rails_helper"

describe TextMessageVerificationCodeService do
  let(:phone_number) { "+18324651680" }
  let(:locale) { "en" }
  let(:visitor_id) { "visitor_id_1" }
  let(:client_id) { nil }
  let(:service_type) { :gyr }
  let(:params) do
    {
        phone_number: phone_number,
        locale: locale,
        visitor_id: visitor_id,
        service_type: service_type
    }
  end
  describe "initialization" do
    context "service_type" do
      let(:service_type) { :unsupported }
      it "raises an error if service_type is not in the list" do
        expect {
          described_class.new(**params)
        }.to raise_error ArgumentError, "Unsupported service_type: unsupported"
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


    it "creates a VerificationTextMessage, sends an email, and creates an EmailAccessToken object" do
      described_class.request_code(**params)

      expect(TwilioService).to have_received(:send_text_message)
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

    context "message sent is different based on service type" do
      let(:service_type) { :ctc }
      context "service_type is :ctc" do
        it "sends a message that mentions GetCTC" do
          described_class.request_code(**params)
          text_body = "Your 6-digit GetCTC verification code is: 123456. This code will expire after two days."

          expect(TwilioService).to have_received(:send_text_message).with(a_hash_including(
                                                                              to: phone_number,
                                                                              body: text_body
                                                                          ))
        end
      end

      context "service_type is :gyr" do
        let(:service_type) { :gyr }
        it "sends a message that mentions GetYourRefund" do
          described_class.request_code(**params)
          text_body = "Your 6-digit GetYourRefund verification code is: 123456. This code will expire after two days."

          expect(TwilioService).to have_received(:send_text_message).with(a_hash_including(
                                                                              to: phone_number,
                                                                              body: text_body
                                                                          ))
        end
      end
    end

    context "when service type is :gyr" do
      let(:matching_intakes) { double }
      let(:service_type) { :gyr }

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
  end
end