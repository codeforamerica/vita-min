require "rails_helper"

describe Ctc::CellPhoneNumberForm do
  let(:intake) { create :intake }

  context "validations" do
    context "when the sms phone number is valid and can_receive_texts is checked" do
      it "is valid" do
        expect(described_class.new(intake, {
          sms_phone_number: "8324658840",
          sms_phone_number_confirmation: "8324658840",
          can_receive_texts: "yes"
        })).to be_valid
      end
    end

    context "when phone number does not match confirmation" do
      it "is not valid" do
        expect(described_class.new(intake, {
          sms_phone_number: "8324658840",
          sms_phone_number_confirmation: "8324658841",
          can_receive_texts: "yes"
        })).not_to be_valid
      end
    end

    context "when phone number is not confirmed" do
      it "is not valid" do
        expect(described_class.new(intake, {
          sms_phone_number: "8324658840",
          sms_phone_number_confirmation: "",
          can_receive_texts: "yes"
        })).not_to be_valid
      end
    end

    context "when phone number cannot receive texts" do
      it "is not valid" do
        expect(described_class.new(intake, {
          sms_phone_number: "8324658840",
          sms_phone_number_confirmation: "8324658840",
          can_receive_texts: "no"
        })).not_to be_valid
      end
    end

    context "when phone number is not a valid phone number" do
      it "is not valid" do
        expect(described_class.new(intake, {
          sms_phone_number: "123",
          sms_phone_number_confirmation: "123",
          can_receive_texts: "no"
        })).not_to be_valid
      end
    end
  end

  describe "#save" do
    it "saves the sms_phone_number and sms_notification_opt_in as yes" do
      expect {
        form = described_class.new(intake, {
            sms_phone_number: "8324658840",
            sms_phone_number_confirmation: "8324658840",
            can_receive_texts: "yes"
        })
        form.valid? # the form only transforms the phone number if it is validated before calling save
        form.save
      }.to change(intake, :sms_phone_number).to("+18324658840")
       .and change(intake, :sms_notification_opt_in).to "yes"
    end

    context "when the phone number gets updated to the existing phone number" do
      let(:intake) { create :intake, sms_phone_number: "+18324658840", sms_phone_number_verified_at: Time.current }
      it "does not clear out the verification and will not force them to re-verify" do
        form = described_class.new(intake, {
            sms_phone_number: "8324658840",
            sms_phone_number_confirmation: "8324658840",
            can_receive_texts: "yes"
        })
        form.valid? # the form only transforms the phone number if it is validated before calling save
        form.save
        expect(intake.reload.sms_phone_number_verified_at).not_to be_nil
      end
    end

    context "when the phone number gets updated to a different phone number" do
      let(:intake) { create :intake, sms_phone_number: "+18324658841", sms_phone_number_verified_at: Time.current }
      it "does not clear out the verification and will not force them to re-verify" do
        form = described_class.new(intake, {
            sms_phone_number: "8324658840",
            sms_phone_number_confirmation: "8324658840",
            can_receive_texts: "yes"
        })
        form.valid? # the form only transforms the phone number if it is validated before calling save
        form.save
        expect(intake.reload.sms_phone_number_verified_at).to be_nil
      end
    end
  end
end