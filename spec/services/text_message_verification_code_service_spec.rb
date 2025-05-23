require "rails_helper"

describe TextMessageVerificationCodeService do
  let(:twilio_service) { instance_double TwilioService }
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
    let(:access_token) { create :text_message_access_token }
    before do
      allow(TwilioService).to receive(:new).and_return twilio_service
      allow(TextMessageAccessToken).to receive(:generate!).and_return ["123456", access_token]
      allow(twilio_service).to receive(:send_text_message).and_return twilio_double
      allow(VerificationTextMessage).to receive(:create!).and_call_original
      allow(twilio_double).to receive(:sid).and_return "twilio_sid"
      allow_any_instance_of(Mail::Message).to receive(:message_id).and_return("mocked_mailer_id")
    end

    it "creates a VerificationTextMessage, sends an email, and creates an TextMessageAccessToken object" do
      described_class.request_code(**params)

      expect(twilio_service).to have_received(:send_text_message)
      expect(TextMessageAccessToken).to have_received(:generate!).with(a_hash_including(
                                                                   sms_phone_number: phone_number,
                                                                   client_id: nil
                                                               ))
      expect(VerificationTextMessage).to have_received(:create!).with(a_hash_including(
                                                                    visitor_id: visitor_id,
                                                                    text_message_access_token: access_token,
                                                                    twilio_sid: "twilio_sid"
                                                                ))
    end

    context "message sent is different based on service type" do
      context "service_type is :ctc" do
        let(:service_type) { :ctc }

        it "sends a message that mentions GetCTC" do
          described_class.request_code(**params)
          text_body = "Your 6-digit GetCTC verification code is: 123456. This code will expire after 10 minutes."

          expect(twilio_service).to have_received(:send_text_message).with(
            a_hash_including(
                to: phone_number,
                body: text_body
            ))
        end
      end

      context "service_type is :gyr" do
        let(:service_type) { :gyr }

        it "sends a message that mentions GetYourRefund" do
          described_class.request_code(**params)
          text_body = "Your 6-digit GetYourRefund verification code is: 123456. This code will expire after 10 minutes."

          expect(twilio_service).to have_received(:send_text_message).with(a_hash_including(
              to: phone_number,
              body: text_body
          ))
        end
      end

      context "service_type is :statefile" do
        let(:service_type) { :statefile }

        it "sends a message that mentions FileYourStateTaxes" do
          described_class.request_code(**params)
          text_body = "Your 6-digit FileYourStateTaxes verification code is: 123456. This code will expire after 10 minutes."

          expect(twilio_service).to have_received(:send_text_message).with(
            a_hash_including(
              to: phone_number,
              body: text_body
            ))
        end
      end
    end

    context "status callback" do
      context "service_type is :gyr" do
        let(:service_type) { :gyr }

        it "includes a callback url" do
          described_class.request_code(**params)

          expect(twilio_service).to have_received(:send_text_message).with(
            a_hash_including(:status_callback)
          )
        end
      end

      context "service_type is :statefile" do
        let(:service_type) { :statefile }

        it "does not include a callback url" do
          described_class.request_code(**params)

          expect(twilio_service).to have_received(:send_text_message).with(
            hash_excluding(:status_callback)
          )
        end
      end
    end
  end
end
