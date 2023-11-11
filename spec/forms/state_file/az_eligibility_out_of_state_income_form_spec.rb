require 'rails_helper'

RSpec.describe StateFile::AzEligibilityOutOfStateIncomeForm do
  let(:intake) {
    build :state_file_az_intake,
          eligibility_out_of_state_income: "unfilled",
          eligibility_529_for_non_qual_expense: "unfilled"
  }

  describe "validations" do
    let(:invalid_params) do
      {
        eligibility_out_of_state_income: nil,
        eligibility_529_for_non_qual_expense: nil,
      }
    end

    it "requires both params" do
      form = described_class.new(intake, invalid_params)
      form.valid?

      expect(form.errors[:eligibility_out_of_state_income]).to include "Can't be blank."
      expect(form.errors[:eligibility_529_for_non_qual_expense]).to include "Can't be blank."
    end
  end

  describe "#save" do
    let(:valid_params) do
      {
        eligibility_out_of_state_income: "yes",
        eligibility_529_for_non_qual_expense: "no",
      }
    end

    it "saves the answers to the intake" do
      form = described_class.new(intake, valid_params)
      form.save
      intake.reload
      expect(intake.eligibility_out_of_state_income_yes?).to eq true
      expect(intake.eligibility_529_for_non_qual_expense_no?).to eq true
    end
  end
end