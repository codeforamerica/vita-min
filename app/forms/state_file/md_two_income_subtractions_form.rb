module StateFile
  class MdTwoIncomeSubtractionsForm < QuestionsForm
    set_attributes_for :intake, :primary_student_loan_interest_ded_amount, :spouse_student_loan_interest_ded_amount

    validate :valid_amounts

    def save
      @intake.update(attributes_for(:intake))
    end

    private

    def valid_amounts
      if @intake.direct_file_data.fed_student_loan_interest.present?
        if (primary_student_loan_interest_ded_amount.to_i + spouse_student_loan_interest_ded_amount.to_i) != @intake.direct_file_data.fed_student_loan_interest.to_i
          errors.add(
            :primary_student_loan_interest_ded_amount,
            I18n.t("state_file.questions.md_two_income_subtractions.edit.sum_form_error", total_deduction: @intake.direct_file_data.fed_student_loan_interest)
          )
        end
      end
    end
  end
end
