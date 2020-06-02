class DemographicSpouseEthnicityForm < QuestionsForm
  set_attributes_for :intake, :demographic_spouse_ethnicity
  validates_presence_of :demographic_spouse_ethnicity, message: I18n.t("forms.validators.answer_presence")

  def save
    @intake.update(attributes_for(:intake))
  end
end