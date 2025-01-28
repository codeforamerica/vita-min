class FinalInfoForm < QuestionsForm
  set_attributes_for :intake, :additional_notes_comments

  def save
    @intake.update(attributes_for(:intake))
  end
end
