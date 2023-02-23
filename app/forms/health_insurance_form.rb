class HealthInsuranceForm < QuestionsForm
  set_attributes_for :intake, :bought_marketplace_health_insurance, :bought_employer_health_insurance, :had_medicaid_medicare, :had_hsa

  def save
    @intake.update(attributes_for(:intake))
  end
end