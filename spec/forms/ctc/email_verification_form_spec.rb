require "rails_helper"

describe Ctc::EmailVerificationForm do
  let(:params) do
    {
      verification_code: '000001'
    }
  end

  describe '#save' do
    before do
      allow(EmailAccessToken).to receive(:lookup).and_return([EmailAccessToken.new])
    end

    context 'when the access token is valid' do
      let(:intake) { create :ctc_intake, email_address: 'foo@example.com', email_notification_opt_in: 'yes' }

      it 'updates the verified_at timestamp for the verification medium used' do
        expect {
          described_class.new(intake, params).save
        }.to change { intake.reload.email_address_verified_at }.from(nil)
      end
    end
  end

  describe "#valid?" do
    let(:intake) { create :ctc_intake, email_address: 'foo@example.com', email_notification_opt_in: 'yes' }
    let(:params) do
      {
        verification_code: '000000'
      }
    end
    let(:form) { Ctc::EmailVerificationForm.new(intake, params) }

    context 'when the environment is demo and code is 000000' do
      before do
        allow(Rails).to receive(:env).and_return("demo".inquiry)
      end

      it 'is valid' do
        expect(form).to be_valid
      end
    end

    context 'when the environment is production and the code is 000000' do
      before do
        allow(Rails).to receive(:env).and_return("production".inquiry)
      end

      it 'is not valid' do
        expect(form).not_to be_valid
      end
    end
  end
end