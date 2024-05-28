require "rails_helper"

RSpec.describe SendOutgoingTextMessageJob, type: :job do
  include MockTwilio

  describe "#perform" do
    let(:user) { create(:user) }
    let(:client) { create(:client) }
    let!(:intake) { create :intake, client: client, locale: "es" }
    let(:error_code) { nil }
    let(:status_code) { nil }
    let(:fake_twilio_message) { double(Twilio::REST::Api::V2010::AccountContext::MessageInstance, sid: "123", status: "sent", error_code: error_code) }
    let(:outgoing_text_message) { create(:outgoing_text_message, body: "body", client: client, user: user, to_phone_number: "+15855551212") }
    let(:fake_time) { Time.utc(2021, 2, 6, 0, 0, 0) }

    context "when Twilio does not raise an exception" do
      before do
        allow_any_instance_of(FakeTwilioMessageContext).to receive(:create).and_return(fake_twilio_message)
      end

      it "replaces sensitive parameters, sends the message to Twilio with a callback URL and saves the status" do
        Timecop.freeze(fake_time) { SendOutgoingTextMessageJob.perform_now(outgoing_text_message.id) }

        outgoing_text_message.reload
        expect(outgoing_text_message.twilio_sid).to eq "123"
        expect(outgoing_text_message.twilio_status).to eq "sent"
        expect(outgoing_text_message.sent_at).to eq fake_time
      end

      context "when the message has an error code" do
        let(:error_code) { '30007' }

        it "persists the error code" do
          Timecop.freeze(fake_time) { SendOutgoingTextMessageJob.perform_now(outgoing_text_message.id) }

          outgoing_text_message.reload
          expect(outgoing_text_message.error_code).to eq "30007"
        end
      end
    end

    context "when Twilio raises an exception" do
      let(:error_code) { '00000' }

      before do
        allow_any_instance_of(FakeTwilioMessageContext).to receive(:create).and_raise(Twilio::REST::RestError.new(error_code, OpenStruct.new(body: {}, status_code: status_code)))
      end

      context "for invalid phone numbers (error 21211)" do
        let(:status_code) { 21211 }

        it "sets the status to twilio_error and exits cleanly" do
          SendOutgoingTextMessageJob.perform_now(outgoing_text_message.id)
          outgoing_text_message.reload
          expect(outgoing_text_message.twilio_status).to eq "twilio_error"
        end
      end

      context "when it fails to get a network connection to twilio" do
        before do
         allow_any_instance_of(FakeTwilioMessageContext).to receive(:create).and_raise(Net::OpenTimeout.new())
        end

        it "sets the status to twilio_error and exits cleanly" do
          expect {
            SendOutgoingTextMessageJob.perform_now(outgoing_text_message.id)
          }.to have_enqueued_job(SendOutgoingTextMessageJob).with(outgoing_text_message.id)

          outgoing_text_message.reload
          expect(outgoing_text_message.twilio_status).to eq "twilio_error"
        end
      end

      context "for other errors" do
        let(:status_code) { 8675309 }

        it "sets the status to twilio_error and raises an exception" do
          expect {
            SendOutgoingTextMessageJob.perform_now(outgoing_text_message.id)
          }.to raise_error(Twilio::REST::RestError)
          outgoing_text_message.reload
          expect(outgoing_text_message.twilio_status).to eq "twilio_error"
        end
      end
    end
  end
end
