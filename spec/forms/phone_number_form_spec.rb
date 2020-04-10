require "rails_helper"

RSpec.describe PhoneNumberForm do
  let(:intake) { create :intake }

  describe "validations" do
    context "when all params are valid" do
      it "is valid" do
        form = PhoneNumberForm.new(
          intake,
          {
            phone_number: "15558675309",
            phone_number_confirmation: "15558675309",
            phone_number_can_receive_texts: "no",
          }
        )

        expect(form).to be_valid
      end

      context "when phone number excludes country code" do
        it "adds one in the setter and is still valid" do
          form = PhoneNumberForm.new(
            intake,
            {
              phone_number: "5558675309",
              phone_number_confirmation: "5558675309",
              phone_number_can_receive_texts: "no",
            }
          )

          expect(form).to be_valid
        end
      end
    end

    context "when phone number is not valid" do
      it "adds an error" do
        form = PhoneNumberForm.new(
          nil,
          {
            phone_number: "555",
            phone_number_confirmation: "555",
            phone_number_can_receive_texts: "no",
          }
        )

        expect(form).not_to be_valid
        expect(form.errors[:phone_number]).to be_present
      end
    end

    context "when phone number confirmation does not match phone number" do
      it "adds an error" do
        form = PhoneNumberForm.new(
          nil,
          {
            phone_number: "5558675309",
            phone_number_confirmation: "5558884444",
            phone_number_can_receive_texts: "no",
          }
        )

        expect(form).not_to be_valid
        expect(form.errors[:phone_number_confirmation]).to be_present
      end
    end
  end
end