require "rails_helper"

RSpec.describe SsnItinForm do
  let(:intake) { create :intake }
  let(:valid_params) do
    {
        primary_ssn: "900500011",
        primary_ssn_confirmation: "900500011",
        primary_tin_type: "ssn"
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
            primary_ssn: nil,
            primary_ssn_confirmation: nil,
            primary_tin_type: nil
          }
        )

        expect(form).not_to be_valid
        expect(form.errors[:primary_ssn]).to be_present
        expect(form.errors[:primary_tin_type]).to be_present
      end
    end

    context "with a primary_ssn that is too short" do
      let(:params) { valid_params.merge(primary_ssn: "765") }

      it "adds a validation error" do
        form = described_class.new(intake, params)

        expect(form).not_to be_valid
        expect(form.errors[:primary_ssn]).to be_present
      end
    end

    context "with a primary_ssn that is too long" do
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

      expect(intake.primary.ssn).to eq "900500011"
      expect(intake.primary.tin_type).to eq "ssn"
    end
  end
end
