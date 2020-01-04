class DebtForgivenForm < QuestionsForm
  set_attributes_for :intake, :had_debt_forgiven

  def save
    @intake.update(attributes_for(:intake))
  end
end