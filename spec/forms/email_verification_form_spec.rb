require "rails_helper"

describe EmailVerificationForm do
  let(:params) do
    {
      verification_code: '000001'
    }
  end

  describe '#save' do
    before do
      allow(EmailAccessToken).to receive(:lookup).and_return([EmailAccessToken.new])
    end

    context 'when email was the verification medium' do
      let(:intake) { create :intake, email_address: 'foo@example.com', email_notification_opt_in: 'yes' }

      it 'updates the verified_at timestamp for the verification medium used' do
        expect {
          described_class.new(intake, params).save
        }.to change { intake.reload.email_address_verified_at }.from(nil)
      end

      it "updates the campaign contact" do
        expect {
          described_class.new(intake, params).save
        }.to change(CampaignContact, :count).by(1)

        contact = CampaignContact.last

        expect(contact).to have_attributes(email_address: "foo@example.com", suppressed_for_gyr_product_year: intake.product_year)
      end
    end
  end

  describe "#valid?" do
    let(:intake) { create :intake, email_address: 'foo@example.com', email_notification_opt_in: 'yes' }
    let(:form) { described_class.new(intake, params) }

    it_behaves_like :a_verification_form_that_accepts_the_magic_code
  end
end
