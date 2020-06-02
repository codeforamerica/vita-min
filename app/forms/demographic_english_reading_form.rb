class DemographicEnglishReadingForm < QuestionsForm
  set_attributes_for :intake, :demographic_english_reading
  validates_presence_of :demographic_english_reading, message: I18n.t("forms.validators.answer_presence")

  def save
    @intake.update(attributes_for(:intake))
  end
end