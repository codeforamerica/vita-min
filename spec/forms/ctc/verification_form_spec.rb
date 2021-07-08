require "rails_helper"

describe Ctc::VerificationForm do
  let(:params) do
    {
        verification_code: '000001'
    }
  end

  describe '#save' do
    before do
      allow(EmailAccessToken).to receive(:lookup).and_return([EmailAccessToken.new])
    end

    context 'when sms was the verification medium' do
      let(:intake) { create :ctc_intake, sms_phone_number: '+15125551234', sms_notification_opt_in: 'yes' }

      it 'updates the verified_at timestamp for the verification medium used' do
        expect {
          described_class.new(intake, params).save
        }.to change { intake.reload.sms_phone_number_verified_at }.from(nil)
      end
    end

    context 'when email was the verification medium' do
      let(:intake) { create :ctc_intake, email_address: 'foo@example.com', email_notification_opt_in: 'yes' }

      it 'updates the verified_at timestamp for the verification medium used' do
        expect {
          described_class.new(intake, params).save
        }.to change { intake.reload.email_address_verified_at }.from(nil)
      end
    end
  end
end