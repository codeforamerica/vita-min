class DemographicPrimaryEthnicityForm < QuestionsForm
  set_attributes_for :intake, :demographic_primary_ethnicity
  validates_presence_of :demographic_primary_ethnicity, message: I18n.t("forms.validators.answer_presence")

  def save
    @intake.update(attributes_for(:intake))
  end
end