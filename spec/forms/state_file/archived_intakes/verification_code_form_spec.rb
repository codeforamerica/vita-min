require "rails_helper"

RSpec.describe StateFile::ArchivedIntakes::VerificationCodeForm do
  let(:params) do
    {
      verification_code: "123456",
    }
  end
  let(:form) {
    StateFile::ArchivedIntakes::VerificationCodeForm.new(
      params,
      email_address: "test@example.com"
    )
  }

  describe "#valid?" do
    context "when the verification code is present and valid" do
      it_behaves_like :a_verification_form_that_accepts_the_magic_code

      it "returns true" do
        allow(VerificationCodeService).to receive(:hash_verification_code_with_contact_info)
                                            .with("test@example.com", "123456")
                                            .and_return("hashed_code")

        allow(EmailAccessToken).to receive_message_chain(:lookup, :exists?).and_return(true)

        expect(form.valid?).to be true
      end
    end

    context "when the verification code is present but invalid" do
      it "adds an error and returns false" do
        allow(VerificationCodeService).to receive(:hash_verification_code_with_contact_info)
                                            .with("test@example.com", "123456")
                                            .and_return("hashed_code")

        allow(EmailAccessToken).to receive_message_chain(:lookup, :exists?).and_return(false)

        expect(form.valid?).to be false
        expect(form.errors[:verification_code]).to include("Incorrect verification code. After 2 failed attempts, accounts are locked.")
      end
    end

    context "when the verification code is blank" do
      let(:params) {
        {
          verification_code: "",
        }
      }
      it "adds an error and returns false" do
        expect(form.valid?).to be false
        expect(form.errors[:verification_code]).to include("Incorrect verification code. After 2 failed attempts, accounts are locked.")
      end
    end
  end

  describe "#initialize" do
    it "assigns attributes correctly" do
      expect(form.verification_code).to eq("123456")
      expect(form.email_address).to eq("test@example.com")
    end
  end
end
