require 'rails_helper'

RSpec.describe StateFile::NyEligibilityOutOfStateIncomeForm do
  let(:intake) {
    build :state_file_ny_intake,
          eligibility_out_of_state_income: "unfilled",
          eligibility_part_year_nyc_resident: "unfilled"
  }

  describe "validations" do
    let(:invalid_params) do
      {
        eligibility_out_of_state_income: nil,
        eligibility_part_year_nyc_resident: nil,
      }
    end

    it "requires both params" do
      form = described_class.new(intake, invalid_params)
      form.valid?

      expect(form.errors[:eligibility_out_of_state_income]).to include "Can't be blank."
      expect(form.errors[:eligibility_part_year_nyc_resident]).to include "Can't be blank."
    end
  end

  describe "#save" do
    let(:valid_params) do
      {
        eligibility_out_of_state_income: "yes",
        eligibility_part_year_nyc_resident: "no",
      }
    end

    it "saves the answers to the intake" do
      form = described_class.new(intake, valid_params)
      form.save
      intake.reload
      expect(intake.eligibility_out_of_state_income_yes?).to eq true
      expect(intake.eligibility_part_year_nyc_resident_no?).to eq true
    end
  end
end