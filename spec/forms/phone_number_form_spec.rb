require "rails_helper"

RSpec.describe PhoneNumberForm do
  let(:intake) { create :intake }

  describe "validations" do
    context "when all params are valid" do
      context "when phone number includes the country code" do
        it "is valid and does not modify the value" do
          form = PhoneNumberForm.new(
            intake,
            {
              phone_number: "1 (415) 553-7865",
              phone_number_confirmation: "1 (415) 553-7865",
              phone_number_can_receive_texts: "no",
            }
          )

          expect(form).to be_valid
          expect(form.attributes_for(:intake)[:phone_number]).to eq "+14155537865"
        end
      end

      context "when phone number excludes country code" do
        it "is valid and prepends a country code" do
          form = PhoneNumberForm.new(
            intake,
            {
              phone_number: "415.553.7865",
              phone_number_confirmation: "415.553.7865",
              phone_number_can_receive_texts: "no",
            }
          )

          expect(form).to be_valid
          expect(form.attributes_for(:intake)[:phone_number]).to eq "+14155537865"
        end
      end

      context "when phone number is a valid Puerto Rico number without country code" do
        it "is valid and prepends a country code" do
          form = PhoneNumberForm.new(
            intake,
            {
              phone_number: "787.764.0000",
              phone_number_confirmation: "787.764.0000",
              phone_number_can_receive_texts: "no",
            }
          )

          expect(form).to be_valid
          expect(form.attributes_for(:intake)[:phone_number]).to eq "+17877640000"
        end
      end
    end

    context "when phone number is not valid" do
      it "adds an error" do
        form = PhoneNumberForm.new(
          nil,
          {
            phone_number: "415",
            phone_number_confirmation: "415",
            phone_number_can_receive_texts: "no",
          }
        )

        expect(form).not_to be_valid
        expect(form.errors[:phone_number]).to be_present
        expect(form.attributes_for(:intake)[:phone_number]).to eq "415"
      end
    end

    context "when phone number confirmation does not match phone number" do
      it "adds an error" do
        form = PhoneNumberForm.new(
          nil,
          {
            phone_number: "4155537865",
            phone_number_confirmation: "4155537811",
            phone_number_can_receive_texts: "no",
          }
        )

        expect(form).not_to be_valid
        expect(form.errors[:phone_number_confirmation]).to be_present
      end
    end
  end
end
