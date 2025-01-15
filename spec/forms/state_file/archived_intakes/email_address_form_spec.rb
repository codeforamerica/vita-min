require "rails_helper"

RSpec.describe StateFile::ArchivedIntakes::EmailAddressForm do
  describe "#valid?" do
    context "when the email address is valid" do
      it "returns true" do
        form = StateFile::ArchivedIntakes::EmailAddressForm.new(email_address: "test@example.com")

        expect(form.valid?).to be true
      end
    end

    context "when the email address is invalid" do
      it "returns false for an improperly formatted email" do
        form = StateFile::ArchivedIntakes::EmailAddressForm.new(email_address: "invalid-email")

        expect(form.valid?).to be false
        expect(form.errors[:email_address]).to include("Please enter a valid email address.")
      end

      it "returns false when the email is blank" do
        form = StateFile::ArchivedIntakes::EmailAddressForm.new(email_address: "")

        expect(form.valid?).to be false
        expect(form.errors[:email_address]).to include("Can't be blank.")
      end
    end
  end

  describe "#initialize" do
    it "assigns attributes correctly" do
      form = StateFile::ArchivedIntakes::EmailAddressForm.new(email_address: "test@example.com")

      expect(form.email_address).to eq("test@example.com")
    end
  end
end
