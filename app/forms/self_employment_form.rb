class SelfEmploymentForm < QuestionsForm
  set_attributes_for :intake, :had_self_employment_income

  def save
    @intake.update(attributes_for(:intake))
  end
end