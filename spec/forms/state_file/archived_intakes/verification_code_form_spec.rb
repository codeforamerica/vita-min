require "rails_helper"

RSpec.describe StateFile::ArchivedIntakes::VerificationCodeForm do
  describe "#valid?" do
    context "when the verification code is present" do
      it "returns true" do
        form = StateFile::ArchivedIntakes::VerificationCodeForm.new(verification_code: "123456")

        expect(form.valid?).to be true
      end
    end

    context "when the verification code is blank" do
      it "returns false" do
        form = StateFile::ArchivedIntakes::VerificationCodeForm.new(verification_code: "")

        expect(form.valid?).to be false
        expect(form.errors[:verification_code]).to include("Can't be blank.")
      end
    end
  end

  describe "#save" do
    context "when the form is valid" do
      it "returns true" do
        form = StateFile::ArchivedIntakes::VerificationCodeForm.new(verification_code: "123456")

        expect(form.save).to be true
      end
    end

    context "when the form is invalid" do
      it "returns false" do
        form = StateFile::ArchivedIntakes::VerificationCodeForm.new(verification_code: "")

        expect(form.save).to be false
      end
    end
  end

  describe "#initialize" do
    it "assigns attributes correctly" do
      form = StateFile::ArchivedIntakes::VerificationCodeForm.new(verification_code: "123456")

      expect(form.verification_code).to eq("123456")
    end
  end
end
