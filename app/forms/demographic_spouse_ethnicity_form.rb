class DemographicSpouseEthnicityForm < QuestionsForm
  set_attributes_for :intake, :demographic_spouse_ethnicity
  validates_presence_of :demographic_spouse_ethnicity, message: "Please answer or click \"Skip question\""

  def save
    @intake.update(attributes_for(:intake))
  end
end