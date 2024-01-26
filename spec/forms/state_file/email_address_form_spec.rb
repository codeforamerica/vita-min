require 'rails_helper'

RSpec.describe StateFile::EmailAddressForm do
  let(:intake) { create :state_file_ny_intake }
  let(:valid_params) do
    { email_address: "someone@example.com" }
  end

  describe "validations" do
    context "no email present" do
      let(:invalid_params) do
        { email_address: "" }
      end
      it "is not valid" do
        form = described_class.new(intake, invalid_params)
        expect(form).not_to be_valid
      end
    end

    context "with an invalid email" do
      let(:invalid_params) do
        { email_address: "someone@example" }
      end
      it "is not valid" do
        form = described_class.new(intake, invalid_params)
        expect(form).not_to be_valid
      end
    end

    context "with a valid email" do
      it "is valid" do
        form = described_class.new(intake, valid_params)
        expect(form).to be_valid
      end
    end
  end

  describe "#save" do
    it "saves the email to the intake" do
      form = described_class.new(intake, valid_params)
      expect do
        form.save
      end.to change(intake, :email_address).to("someone@example.com")
    end
  end
end