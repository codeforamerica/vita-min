require 'rails_helper'

RSpec.describe StateFile::VerificationCodeForm do
  let(:intake) { create :state_file_ny_intake }

  describe "#valid?" do
    describe "verification_code" do
      context "without a verification code" do
        it "returns false and adds an error" do
          form = described_class.new(intake, { verification_code: "" })

          expect(form).not_to be_valid
          expect(form.errors).to include(:verification_code)
        end
      end

      context "when the magic verification code is enabled" do
        before do
          allow(Rails.configuration).to receive(:allow_magic_verification_code).and_return(true)
        end

        it "will accept the magic verification code as valid" do
          form = described_class.new(intake, { verification_code: "000000" })
          expect(form).to be_valid
        end
      end

      context "when the intake is using email" do
        let(:intake) { create :state_file_ny_intake, contact_preference: :email, email_address: "someone@example.com" }

        context "when the verification code with email has a match" do
          let(:verification_code) do
            EmailAccessToken.generate!(email_address: intake.email_address).first
          end

          it "returns true" do
            form = described_class.new(intake, { verification_code: verification_code })
            expect(form).to be_valid
          end
        end

        context "when there is no matching verification code with the same email" do
          it "returns false and adds an error" do
            form = described_class.new(intake, { verification_code: "123456" })
            expect(form).not_to be_valid
            expect(form.errors).to include :verification_code
          end
        end
      end

      context "when the intake is using text messaging" do
        let(:intake) { create :state_file_ny_intake, contact_preference: :text, phone_number: "+14155551212" }

        context "when the verification code with phone number has a match" do
          let(:verification_code) do
            TextMessageAccessToken.generate!(sms_phone_number: intake.phone_number).first
          end

          it "returns true" do
            form = described_class.new(intake, { verification_code: verification_code })
            expect(form).to be_valid
          end
        end

        context "when there is no matching verification code with the same phone number" do
          it "returns false and adds an error" do
            form = described_class.new(intake, { verification_code: "123456" })
            expect(form).not_to be_valid
            expect(form.errors).to include :verification_code
          end
        end
      end
    end
  end

  describe "#save" do
    context "when the intake is using email" do
      before do
        Flipper.enable :state_file_notification_emails
      end

      let(:intake) { create :state_file_ny_intake, contact_preference: :email, email_address: "someone@example.com" }
      let(:verification_code) do
        EmailAccessToken.generate!(email_address: intake.email_address).first
      end

      it "timestamps the email verification" do
        form = described_class.new(intake, verification_code: verification_code)
        expect {
          form.save
        }.to change(intake, :email_address_verified_at).from(nil)
      end

      it "sends a welcome email" do
        form = described_class.new(intake, verification_code: verification_code)
        expect {
          form.save
        }.to change { StateFileNotificationEmail.where(to: intake.email_address).count }.from(0).to(1)
      end
    end

    context "when the intake is using text message" do
      let(:intake) { create :state_file_ny_intake, contact_preference: :text, phone_number: "+14155551212" }
      let(:verification_code) do
        TextMessageAccessToken.generate!(sms_phone_number: intake.phone_number).first
      end

      it "timestamps the phone number verification" do
        form = described_class.new(intake, verification_code: verification_code)
        expect {
          form.save
        }.to change(intake, :phone_number_verified_at).from(nil)
      end
    end
  end
end