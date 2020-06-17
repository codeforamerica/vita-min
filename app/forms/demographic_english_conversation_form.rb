class DemographicEnglishConversationForm < QuestionsForm
  set_attributes_for :intake, :demographic_english_conversation
  validates_presence_of :demographic_english_conversation

  def save
    @intake.update(attributes_for(:intake))
  end
end
