class TipsForm < QuestionsForm
  set_attributes_for :intake, :had_tips

  def save
    @intake.update(attributes_for(:intake))
  end
end