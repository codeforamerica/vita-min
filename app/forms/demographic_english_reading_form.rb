class DemographicEnglishReadingForm < QuestionsForm
  set_attributes_for :intake, :demographic_english_reading
  validates_presence_of :demographic_english_reading

  def save
    @intake.update(attributes_for(:intake))
  end
end
