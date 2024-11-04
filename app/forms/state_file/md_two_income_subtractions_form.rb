module StateFile
  class MdTwoIncomeSubtractionsForm < QuestionsForm
    set_attributes_for :intake, :student_loan_interest_ded_amount_cents, :spouse_student_loan_interest_ded_amount_cents

    validate :valid_amounts

    def save
      @intake.update(attributes_for(:intake))
    end

    private

    def valid_amounts
      if @intake.direct_file_data.fed_student_loan_interest.present?
        if (student_loan_interest_ded_amount_cents.to_i + spouse_student_loan_interest_ded_amount_cents.to_i) != @intake.direct_file_data.fed_student_loan_interest.to_i
          errors.add(
            :student_loan_interest_ded_amount_cents,
            I18n.t("state_file.questions.md_two_income_subtractions.edit.sum_form_error", total_deduction: @intake.direct_file_data.fed_student_loan_interest)
          )
        end
      end
    end
  end
end
