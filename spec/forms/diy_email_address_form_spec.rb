require "rails_helper"

describe DiyEmailAddressForm do
  # TODO remove this initial `email_address` value as part of GYR1-877.
  let(:diy_intake) { create :diy_intake, email_address: 'test@test.test' }

  context "validations" do
    it_behaves_like "email address validation", EmailAddressForm do
      let(:form_object) { diy_intake }
    end
  end

  describe "#save" do
    it "saves the email address" do
      expect {
        described_class.new(diy_intake, {
          email_address: "mango@fruitnames.test",
          email_address_confirmation: "mango@fruitnames.test"
        }).save
      }.to change(diy_intake, :email_address).to("mango@fruitnames.test")
    end

    context "when the email address gets updated to a new address" do
      let(:diy_intake) { create :diy_intake, email_address: "martin@fruitnames.test" }
      it "saves the updated email address" do
        expect {
          described_class.new(diy_intake, {
            email_address: "mango@fruitnames.test",
            email_address_confirmation: "mango@fruitnames.test"
          }).save
        }.to change(diy_intake, :email_address).to("mango@fruitnames.test")
      end
    end
  end
end
