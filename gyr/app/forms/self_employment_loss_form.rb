class SelfEmploymentLossForm < QuestionsForm
  set_attributes_for :intake, :reported_self_employment_loss

  def save
    @intake.update(attributes_for(:intake))
  end
end