require 'rails_helper'

describe BulkAction::SendOneBulkSignupMessageJob do
  describe '#perform' do
    let(:signup) { create :signup }
    let(:bulk_signup_message) { create(:bulk_signup_message, message_type: message_type, signup_selection: build(:signup_selection, id_array: [signup.id]), message: "We are now open") }

    context "when sending any kind of message" do
      let(:message_type) { "sms" }

      it "creates a outgoing message status & join record" do
        expect {
          expect {
            described_class.perform_now(signup, bulk_signup_message)
          }.to(change(OutgoingMessageStatus, :count).by(1))
        }.to change(BulkSignupMessageOutgoingMessageStatus, :count).by(1)

        outgoing_message_status = OutgoingMessageStatus.last
        expect(outgoing_message_status.message_type).to eq(message_type)
        expect(outgoing_message_status.parent).to eq signup
        expect(outgoing_message_status.delivery_status).to eq nil

        join_record = BulkSignupMessageOutgoingMessageStatus.last
        expect(join_record.outgoing_message_status).to eq outgoing_message_status
        expect(join_record.bulk_signup_message).to eq bulk_signup_message
      end
    end

    context 'with an sms signup' do
      let(:message_type) { 'sms' }
      let(:twilio_double) { double TwilioService }
      before do
        allow(TwilioService).to receive(:send_text_message).and_return twilio_double
        allow(twilio_double).to receive(:sid).and_return "twilio_sid"
        allow(twilio_double).to receive(:status).and_return "queued"
      end

      it 'sends an sms and saves the twilio message id' do
        described_class.perform_now(signup, bulk_signup_message)
        outgoing_message_status = OutgoingMessageStatus.last
        expect(TwilioService).to have_received(:send_text_message).with(
          to: signup.phone_number,
          body: bulk_signup_message.message,
          status_callback: twilio_update_status_url(outgoing_message_status.id, locale: nil),
          outgoing_text_message: outgoing_message_status
        )
        expect(outgoing_message_status.message_type).to eq 'sms'
        expect(outgoing_message_status.message_id).to eq 'twilio_sid'
        expect(outgoing_message_status.delivery_status).to eq nil
      end

      context "when phone number is a landline" do
        before do
          allow(TwilioService).to receive(:get_metadata).and_return({ "type" => "landline" })
          allow(DatadogApi).to receive(:increment)
        end

        it "does not send a text and updates the record's delivery_status" do
          signup = create(:signup)
          bulk_signup_message = create(:bulk_signup_message, message_type: "sms")
          expect {
            described_class.perform_now(signup, bulk_signup_message)
          }.not_to change(BulkSignupMessageOutgoingMessageStatus, :count)

          expect(TwilioService).not_to have_received(:send_text_message)
          expect(DatadogApi).to have_received(:increment).with("twilio.outgoing_text_messages.bulk_signup_message_not_sent_landline")
        end
      end
    end

    context 'with email signup' do
      let(:message_type) { 'email' }

      before do
        bulk_signup_message.update(subject: "Please come to our website")
      end

      it 'sends an email and saves the mailgun message id' do
        expect {
          described_class.perform_now(signup, bulk_signup_message)
        }.to change(ActionMailer::Base.deliveries, :count).by(1)
        mail = ActionMailer::Base.deliveries.last
        expect(mail.body.encoded).to include bulk_signup_message.message
        expect(mail.subject).to include bulk_signup_message.subject
        expect(mail.to).to eq [signup.email_address]

        message_status = OutgoingMessageStatus.last
        expect(message_status.message_id).to eq mail.message_id
        expect(message_status.message_type).to eq 'email'
      end

      context "subject & from address" do
        context "with a CTC signup" do
          let(:signup) { create :ctc_signup }
          it "uses the default no-reply address" do
            described_class.perform_now(signup, bulk_signup_message)
            mail = ActionMailer::Base.deliveries.last
            expect(mail.from).to eq ["no-reply@ctc.test.localhost"]
          end
        end

        context "with a GYR signup" do
          it "uses the default no-reply address" do
            described_class.perform_now(signup, bulk_signup_message)
            mail = ActionMailer::Base.deliveries.last
            expect(mail.from).to eq ["no-reply@test.localhost"]
          end
        end
      end
    end
  end
end
