require 'rails_helper'

RSpec.describe StateFile::IdEligibilityResidenceForm do
  let(:intake) {
    create :state_file_id_intake,
           eligibility_withdrew_msa_fthb: "unfilled",
           eligibility_emergency_rental_assistance: "unfilled"
  }

  describe "validations" do
    let(:invalid_params) do
      {
        eligibility_withdrew_msa_fthb: nil,
        eligibility_emergency_rental_assistance: nil,
      }
    end

    it "requires both params" do
      form = described_class.new(intake, invalid_params)
      form.valid?

      expect(form.errors[:eligibility_withdrew_msa_fthb]).to include "Can't be blank."
      expect(form.errors[:eligibility_emergency_rental_assistance]).to include "Can't be blank."
    end
  end

  describe "#save" do
    let(:valid_params) do
      {
        eligibility_withdrew_msa_fthb: "no",
        eligibility_emergency_rental_assistance: "no",
      }
    end

    it "saves the answers to the intake" do
      form = described_class.new(intake, valid_params)
      form.save
      intake.reload
      expect(intake.eligibility_withdrew_msa_fthb_no?).to eq true
      expect(intake.eligibility_emergency_rental_assistance_no?).to eq true
    end
  end
end