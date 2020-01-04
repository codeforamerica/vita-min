class MortgageInterestForm < QuestionsForm
  set_attributes_for :intake, :paid_mortgage_interest

  def save
    @intake.update(attributes_for(:intake))
  end
end