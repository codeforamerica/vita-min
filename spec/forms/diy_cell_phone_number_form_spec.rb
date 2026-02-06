require "rails_helper"

RSpec.describe DiyCellPhoneNumberForm do
  let(:diy_intake) { create :diy_intake, email_address: 'test@test.test' }

  describe "validations" do
    context "when all params are valid" do
      context "when phone number includes the country code" do
        it "is valid and does not modify the value" do
          form = DiyCellPhoneNumberForm.new(
            diy_intake,
            {
              sms_phone_number: "1 (415) 553-7865",
              sms_phone_number_confirmation: "1 (415) 553-7865",
            }
          )

          expect(form).to be_valid
          expect(form.attributes_for(:diy_intake)[:sms_phone_number]).to eq "+14155537865"
        end
      end

      context "when phone number excludes country code" do
        it "is valid and prepends a country code" do
          form = DiyCellPhoneNumberForm.new(
            diy_intake,
            {
              sms_phone_number: "415.553.7865",
              sms_phone_number_confirmation: "415.553.7865",
            }
          )

          expect(form).to be_valid
          expect(form.attributes_for(:diy_intake)[:sms_phone_number]).to eq "+14155537865"
        end
      end
    end

    context "when phone number is not valid" do
      it "adds an error" do
        form = DiyCellPhoneNumberForm.new(
          nil,
          {
            sms_phone_number: "415",
            sms_phone_number_confirmation: "415",
          }
        )

        expect(form).not_to be_valid
        expect(form.errors[:sms_phone_number]).to be_present
        expect(form.attributes_for(:diy_intake)[:sms_phone_number]).to eq "415"
      end
    end

    context "when phone number confirmation does not match phone number" do
      it "adds an error" do
        form = DiyCellPhoneNumberForm.new(
          nil,
          {
            sms_phone_number: "4155537865",
            sms_phone_number_confirmation: "4155537811",
          }
        )

        expect(form).not_to be_valid
        expect(form.errors[:sms_phone_number_confirmation]).to be_present
      end
    end
  end
end

