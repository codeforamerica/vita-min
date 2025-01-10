require "rails_helper"

RSpec.describe StateFile::ArchivedIntakes::VerificationCodeForm do
  describe "#valid?" do
    context "when the verification code is present and valid" do
      it "returns true" do
        allow(VerificationCodeService).to receive(:hash_verification_code_with_contact_info)
                                            .with("test@example.com", "123456")
                                            .and_return("hashed_code")

        allow(EmailAccessToken).to receive_message_chain(:lookup, :exists?).and_return(true)

        form = StateFile::ArchivedIntakes::VerificationCodeForm.new(
          { verification_code: "123456" },
          email_address: "test@example.com"
        )

        expect(form.valid?).to be true
      end
    end

    context "when the verification code is present but invalid" do
      it "adds an error and returns false" do
        allow(VerificationCodeService).to receive(:hash_verification_code_with_contact_info)
                                            .with("test@example.com", "123456")
                                            .and_return("hashed_code")

        allow(EmailAccessToken).to receive_message_chain(:lookup, :exists?).and_return(false)

        form = StateFile::ArchivedIntakes::VerificationCodeForm.new(
          { verification_code: "123456" },
          email_address: "test@example.com"
        )

        expect(form.valid?).to be false
        expect(form.errors[:verification_code]).to include("Incorrect verification code. After 2 failed attempts, accounts are locked.")
      end
    end

    context "when the verification code is blank" do
      it "adds a presence error and returns false" do
        form = StateFile::ArchivedIntakes::VerificationCodeForm.new(
          { verification_code: "" },
          email_address: "test@example.com"
        )

        expect(form.valid?).to be false
        expect(form.errors[:verification_code]).to include("can't be blank")
      end
    end
  end

  describe "#save" do
    context "when the form is valid" do
      it "returns true" do
        allow(VerificationCodeService).to receive(:hash_verification_code_with_contact_info)
                                            .with("test@example.com", "123456")
                                            .and_return("hashed_code")

        allow(EmailAccessToken).to receive_message_chain(:lookup, :exists?).and_return(true)

        form = StateFile::ArchivedIntakes::VerificationCodeForm.new(
          { verification_code: "123456" },
          email_address: "test@example.com"
        )

        expect(form.save).to be true
      end
    end

    context "when the form is invalid" do
      it "returns false" do
        allow(VerificationCodeService).to receive(:hash_verification_code_with_contact_info)
                                            .with("test@example.com", "")
                                            .and_return("hashed_code")

        allow(EmailAccessToken).to receive_message_chain(:lookup, :exists?).and_return(false)

        form = StateFile::ArchivedIntakes::VerificationCodeForm.new(
          { verification_code: "" },
          email_address: "test@example.com"
        )

        expect(form.save).to be false
      end
    end
  end

  describe "#initialize" do
    it "assigns attributes correctly" do
      form = StateFile::ArchivedIntakes::VerificationCodeForm.new(
        { verification_code: "123456" },
        email_address: "test@example.com"
      )

      expect(form.verification_code).to eq("123456")
      expect(form.email_address).to eq("test@example.com")
    end
  end
end
