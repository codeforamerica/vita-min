class MedicalExpensesForm < QuestionsForm
  set_attributes_for :intake, :paid_medical_expenses

  def save
    @intake.update(attributes_for(:intake))
  end
end