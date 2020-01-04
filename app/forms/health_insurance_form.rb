class HealthInsuranceForm < QuestionsForm
  set_attributes_for :intake, :bought_health_insurance

  def save
    @intake.update(attributes_for(:intake))
  end
end