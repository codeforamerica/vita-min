class DemographicPrimaryEthnicityForm < QuestionsForm
  set_attributes_for :intake, :demographic_primary_ethnicity

  def save
    @intake.update(attributes_for(:intake))
  end
end