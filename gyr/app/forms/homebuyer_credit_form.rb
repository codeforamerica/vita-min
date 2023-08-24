class HomebuyerCreditForm < QuestionsForm
  set_attributes_for :intake, :received_homebuyer_credit

  def save
    @intake.update(attributes_for(:intake))
  end
end