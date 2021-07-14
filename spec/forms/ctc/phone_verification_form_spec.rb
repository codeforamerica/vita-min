require "rails_helper"

describe Ctc::PhoneVerificationForm do
  let(:params) do
    {
        verification_code: '000001'
    }
  end

  describe '#save' do
    before do
      allow(TextMessageAccessToken).to receive(:lookup).and_return([TextMessageAccessToken.new])
    end

    context 'when sms was the verification medium' do
      let(:intake) { create :ctc_intake, sms_phone_number: '+15125551234', sms_notification_opt_in: 'yes' }

      it 'updates the verified_at timestamp for the verification medium used' do
        expect {
          described_class.new(intake, params).save
        }.to change { intake.reload.sms_phone_number_verified_at }.from(nil)
      end
    end
  end
end