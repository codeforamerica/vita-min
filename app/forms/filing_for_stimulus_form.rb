class FilingForStimulusForm < QuestionsForm
  set_attributes_for :intake, :filing_for_stimulus

  def save
    @intake.update(attributes_for(:intake))
  end
end
