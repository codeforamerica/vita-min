class IrsLetterForm < QuestionsForm
  set_attributes_for :intake, :received_irs_letter

  def save
    @intake.update(attributes_for(:intake))
  end
end