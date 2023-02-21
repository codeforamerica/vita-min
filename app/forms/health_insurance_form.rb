class HealthInsuranceForm < QuestionsForm
  set_attributes_for :intake, :bought_health_insurance, :bought_employer_health_insurance, :had_medicaid_medicare, :had_hsa

  def save
    additional_attributes = { bought_marketplace_health_insurance: bought_health_insurance }
    @intake.update(attributes_for(:intake).merge(additional_attributes))
  end
end