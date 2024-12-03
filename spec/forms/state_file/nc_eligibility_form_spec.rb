require 'rails_helper'

RSpec.describe StateFile::NcEligibilityForm do
  let(:intake) {
    build :state_file_nc_intake,
          eligibility_ed_loan_emp_payment: "no",
          eligibility_ed_loan_cancelled: "no"
  }

  describe "validations" do
    let(:invalid_params) do
      {
        eligibility_ed_loan_emp_payment: "no",
        eligibility_ed_loan_cancelled: "no",
        nc_eligiblity_none: "no",
      }
    end

    it "requires at least one" do
      form = described_class.new(intake, invalid_params)
      form.valid?
      expect(form.errors[:nc_eligiblity_none]).to eq ["You must either select none or the above options"]
    end

    context "selected none option" do
      let(:invalid_params) do
        {
          eligibility_ed_loan_emp_payment: nil,
          eligibility_ed_loan_cancelled: "yes",
          nc_eligiblity_none: "yes",
        }
      end
      let(:form) { described_class.new(intake, invalid_params) }

      it "validates that another option wasn't also selected" do
        form.valid?
        expect(form.errors[:nc_eligiblity_none]).to eq ["You must either select none or the above options"]
      end
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
