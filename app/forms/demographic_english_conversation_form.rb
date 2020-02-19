class DemographicEnglishConversationForm < QuestionsForm
  set_attributes_for :intake, :demographic_english_conversation
  validates_presence_of :demographic_english_conversation, message: "Please answer or click \"Skip question\""

  def save
    @intake.update(attributes_for(:intake))
  end
end