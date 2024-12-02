require 'rails_helper'

RSpec.describe StateFile::NcEligibilityForm do
  let(:intake) {
    build :state_file_nc_intake,
          eligibility_ed_loan_emp_payment: "unfilled",
          eligibility_ed_loan_cancelled: "unfilled"
  }

  describe "validations" do
    let(:invalid_params) do
      {
        eligibility_ed_loan_emp_payment: nil,
        eligibility_ed_loan_cancelled: nil,
      }
    end

    it "does not requires both params" do
      form = described_class.new(intake, invalid_params)
      form.valid?

      expect(form.errors[:eligibility_ed_loan_emp_payment]).to be_empty
      expect(form.errors[:eligibility_ed_loan_cancelled]).to be_empty
    end
  end

  describe "#save" do
    let(:valid_params) do
      {
        eligibility_ed_loan_emp_payment: "yes",
        eligibility_ed_loan_cancelled: "no",
      }
    end

    it "saves the answers to the intake" do
      form = described_class.new(intake, valid_params)
      form.save
      intake.reload
      expect(intake.eligibility_ed_loan_emp_payment_yes?).to eq true
      expect(intake.eligibility_ed_loan_cancelled_no?).to eq true
    end
  end
end
