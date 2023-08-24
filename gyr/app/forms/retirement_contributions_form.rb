class RetirementContributionsForm < QuestionsForm
  set_attributes_for :intake, :paid_retirement_contributions

  def save
    @intake.update(attributes_for(:intake))
  end
end