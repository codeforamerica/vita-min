require "rails_helper"

RSpec.describe StateFile::MdTwoIncomeSubtractionsForm do
  let(:intake) do
    create :state_file_md_intake, primary_student_loan_interest_ded_amount: nil, spouse_student_loan_interest_ded_amount: nil
  end

  describe "#save" do
    # df_data_many_w2s has a fed_student_loan_interest of 1300
    let(:intake) { create(:state_file_md_intake, :with_spouse, :df_data_many_w2s) }
    let(:params) do
      {
        primary_student_loan_interest_ded_amount: "100",
        spouse_student_loan_interest_ded_amount: "200"
      }
    end
    let(:form) { described_class.new(intake, params) }

    context "validations" do
      context "with invalid amounts" do
        it "returns false and adds an error to the form" do
          expect(form.valid?).to eq false
          expect(form.errors[:primary_student_loan_interest_ded_amount]).to include(I18n.t("state_file.questions.md_two_income_subtractions.edit.sum_form_error", total_deduction: 1300))
        end
      end

      context "with valid amounts" do
        let(:params) do
          {
            primary_student_loan_interest_ded_amount: "900.0",
            spouse_student_loan_interest_ded_amount: "400.0"
          }
        end

        it "returns true and updates the intake" do
          expect(form.valid?).to eq true
          form.save
          intake.reload
          expect(intake.primary_student_loan_interest_ded_amount).to eq 900.0
          expect(intake.spouse_student_loan_interest_ded_amount).to eq 400.0
        end
      end
    end
  end
end
