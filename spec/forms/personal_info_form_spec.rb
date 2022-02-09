require "rails_helper"

RSpec.describe PersonalInfoForm do
  let(:intake) { create :intake }
  let(:valid_params) do
    {
        preferred_name: "Greta",
        phone_number: "8286065544",
        phone_number_confirmation: "828-606-5544",
        zip_code: "94107",
        primary_ssn: "123456789",
        primary_ssn_confirmation: "123456789",
        primary_tin_type: "ssn"
      }
  end

  describe "validations" do
    context "when all params are valid" do
      it "is valid" do
        form = described_class.new(intake, valid_params)

        expect(form).to be_valid
      end

      context "when all ssn fields are missing" do
        let!(:triage) { create :triage, intake: intake, id_type: "need_help" }

        let(:valid_params) do
          {
            preferred_name: "Greta",
            phone_number: "8286065544",
            phone_number_confirmation: "828-606-5544",
            zip_code: "94107",
          }
        end

        it "is still valid if client needs help getting an ITIN" do
          form = described_class.new(intake, valid_params)

          expect(form).to be_valid
        end
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
            primary_ssn: nil,
            primary_ssn_confirmation: nil,
            primary_tin_type: nil
          }
        )

        expect(form).not_to be_valid
        expect(form.errors[:preferred_name]).to be_present
        expect(form.errors[:phone_number_confirmation]).to be_present
        expect(form.errors[:zip_code]).to be_present
        expect(form.errors[:primary_ssn]).to be_present
        expect(form.errors[:primary_tin_type]).to be_present
      end
    end

    context "with a last_four_ssn that is too short" do
      let(:params) { valid_params.merge(primary_ssn: "765") }

      it "adds a validation error" do
        form = described_class.new(intake, params)

        expect(form).not_to be_valid
        expect(form.errors[:primary_ssn]).to be_present
      end
    end

    context "with a last_four_ssn that is too long" do
      let(:params) { valid_params.merge(primary_ssn: "12345678987654323") }

      it "adds a validation error" do
        form = described_class.new(intake, params)

        expect(form).not_to be_valid
        expect(form.errors[:primary_ssn]).to be_present
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
      expect(intake.primary_ssn).to eq "123456789"
      expect(intake.primary_tin_type).to eq "ssn"
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