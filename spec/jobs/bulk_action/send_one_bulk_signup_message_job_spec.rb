require 'rails_helper'

describe BulkAction::SendOneBulkSignupMessageJob do
  describe '#perform' do
    let(:signup) { create :signup }
    let(:bulk_signup_message) { create(:bulk_signup_message, message_type: message_type, signup_selection: build(:signup_selection, id_array: [signup.id]), message: "We are now open") }

    context 'an email signup' do
      let(:message_type) { 'email' }

      it 'sends an email and saves the mailgun message id' do
        expect {
          described_class.perform_now(signup, bulk_signup_message)
        }.to change(OutgoingMessageStatus, :count).from(0).to(1)

        message_status = OutgoingMessageStatus.last
        expect(message_status.message_id).to eq 'mailgun-message-id'
        expect(message_status.delivery_status).to eq 'pending'
        expect(message_status.message_type).to eq 'email'
      end
    end

    context 'an sms signup' do
      let(:message_type) { 'sms' }

      it 'sends an sms and saves the twilio message id' do
        expect {
          described_class.perform_now(signup, bulk_signup_message)
        }.to change(OutgoingMessageStatus, :count).from(0).to(1)

        message_status = OutgoingMessageStatus.last
        expect(message_status.message_id).to eq 'twilio-message-id'
        expect(message_status.delivery_status).to eq 'pending'
        expect(message_status.message_type).to eq 'sms'
      end
    end
  end
end
