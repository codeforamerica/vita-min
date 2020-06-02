class DemographicVeteranForm < QuestionsForm
  set_attributes_for :intake, :demographic_veteran
  validates_presence_of :demographic_veteran, message: I18n.t("forms.validators.answer_presence")

  def save
    @intake.update(attributes_for(:intake))
  end
end