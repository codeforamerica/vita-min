require "rails_helper"

RSpec.describe Portal::VerificationCodeForm do
  describe "validations" do
    context "valid params" do
      let(:valid_params) {
        {
          verification_code: "123456",
          contact_info: "email@example.boring"
        }
      }

      it "is valid" do
        expect(described_class.new(valid_params)).to be_valid
      end
    end

    context "invalid params" do
      let(:invalid_params) {
        {
          verification_code: "awordperhaps",
          contact_info: "email@example.boring"
        }
      }

      it "is not valid" do
        subject = described_class.new(invalid_params)
        expect(subject).not_to be_valid

        expect(subject.errors[:verification_code]).to be_present
      end
    end
  end

  describe "#formatted_contact_info" do
    it "formats phone numbers" do
      form = described_class.new({
        contact_info: "+14155551212"
      })

      expect(form.formatted_contact_info).to eq "(415) 555-1212"
    end

    it "does not do anything to email addresses" do
      form = described_class.new({
        contact_info: "email@example.boring"
      })

      expect(form.formatted_contact_info).to eq "email@example.boring"
    end
  end
end

