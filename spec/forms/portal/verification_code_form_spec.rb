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
end

