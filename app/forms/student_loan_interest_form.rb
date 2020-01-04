class StudentLoanInterestForm < QuestionsForm
  set_attributes_for :intake, :paid_student_loan_interest

  def save
    @intake.update(attributes_for(:intake))
  end
end