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
    let(:form) { described_class.new(intake, params) }

    it_behaves_like :a_verification_form_that_accepts_the_magic_code
  end
end
