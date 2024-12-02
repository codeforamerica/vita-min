module StateFile
  class NcEligibilityForm < QuestionsForm
    set_attributes_for :intake, :eligibility_ed_loan_cancelled, :eligibility_ed_loan_emp_payment

    def save
      @intake.update(attributes_for(:intake))
    end
  end
end
