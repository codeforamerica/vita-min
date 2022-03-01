require "rails_helper"

RSpec.describe PersonalInfoForm do
  let(:intake) { create :intake }
  let(:valid_params) do
    {
        preferred_name: "Greta",
        phone_number: "8286065544",
        phone_number_confirmation: "828-606-5544",
        zip_code: "94107",
      }
  end

  describe "validations" do
    context "when all params are valid" do
      it "is valid" do
        form = described_class.new(intake, valid_params)

        expect(form).to be_valid
      end
    end

    context "required params are missing" do
      it "adds errors for each" do
        form = described_class.new(
          intake,
          {
            preferred_name: nil,
            phone_number: "8286065544",
            phone_number_confirmation: nil,
            zip_code: nil,
          }
        )

        expect(form).not_to be_valid
        expect(form.errors[:preferred_name]).to be_present
        expect(form.errors[:phone_number_confirmation]).to be_present
        expect(form.errors[:zip_code]).to be_present
      end
    end
  end

  describe "#save" do
    it "parses & saves the correct data to the model record" do
      form = described_class.new(intake, valid_params)
      expect(form).to be_valid
      form.save
      intake.reload

      expect(intake.state_of_residence).to eq "CA"
      expect(intake.phone_number).to eq "+18286065544"
    end
  end

  describe "#existing_attributes" do
    let(:populated_intake) { build :intake, phone_number: "+18286065544" }

    it "returns a hash with the date fields populated" do
      attributes = described_class.existing_attributes(populated_intake)

      expect(attributes[:phone_number]).to eq "+18286065544"
    end
  end
end