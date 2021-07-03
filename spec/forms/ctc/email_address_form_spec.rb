require "rails_helper"

describe Ctc::EmailAddressForm do
  let(:intake) { create :intake }

  context "validations" do
    it_behaves_like "email address validation", Ctc::EmailAddressForm do
      let(:form_object) { intake }
    end
  end

  describe "#save" do
    it "saves the email address and email_notification_opt_in as yes" do
      expect {
        described_class.new(intake, {
            email_address: "mango@fruitnames.com",
            email_address_confirmation: "mango@fruitnames.com"
        }).save
      }.to change(intake, :email_address).to("mango@fruitnames.com")
       .and change(intake, :email_notification_opt_in).to "yes"
    end
  end
end