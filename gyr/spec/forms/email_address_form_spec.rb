require "rails_helper"

describe EmailAddressForm do
  let(:intake) { create :intake }

  context "validations" do
    it_behaves_like "email address validation", EmailAddressForm do
      let(:form_object) { intake }
    end
  end

  describe "#save" do
    it "saves the email address" do
      expect {
        described_class.new(intake, {
          email_address: "mango@fruitnames.com",
          email_address_confirmation: "mango@fruitnames.com"
        }).save
      }.to change(intake, :email_address).to("mango@fruitnames.com")
    end

    context "when the email address gets updated to the existing address" do
      let(:intake) { create :intake, email_address: "mango@fruitnames.com", email_address_verified_at: Time.current }
      it "does not clear out the verification and will not force them to re-verify" do
        described_class.new(intake, {
          email_address: "mango@fruitnames.com",
          email_address_confirmation: "mango@fruitnames.com"
        }).save
        expect(intake.reload.email_address_verified_at).not_to be_nil
      end
    end

    context "when the email address gets updated to a new address" do
      let(:intake) { create :intake, email_address: "martin@fruitnames.com", email_address_verified_at: Time.current }
      it "does clear out the verification and will force them to re-verify" do
        described_class.new(intake, {
          email_address: "mango@fruitnames.com",
          email_address_confirmation: "mango@fruitnames.com"
        }).save
        expect(intake.reload.email_address_verified_at).to be_nil
      end
    end
  end
end