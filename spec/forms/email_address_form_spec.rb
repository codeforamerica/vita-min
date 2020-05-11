require "rails_helper"

RSpec.describe EmailAddressForm do
  let(:intake) { create :intake }

  describe "validations" do
    context "when the email is valid" do
      it "is valid" do

        form = EmailAddressForm.new(
          intake,
          {
            email_address: "stuff@things.net",
            email_address_confirmation: "stuff@things.net"
          }
        )

        expect(form).to be_valid
      end
    end

    context "when the email does not have a top level domain" do
      it "is not valid" do

        form = EmailAddressForm.new(
          intake,
          {
            email_address: "stuff@things",
            email_address_confirmation: "stuff@things"
          }
        )

        expect(form).not_to be_valid
        expect(form.errors[:email_address]).to be_present
      end
    end

    context "when there is whitespace mismatch with confirmation email" do
      it "is valid" do
        form = EmailAddressForm.new(
          intake,
          {
            email_address: "stuff@things.net",
            email_address_confirmation: " stuff@things.net "
          }
        )

        expect(form).to be_valid
      end
    end
  end
end