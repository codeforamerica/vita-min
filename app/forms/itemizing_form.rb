class ItemizingForm < QuestionsForm
  set_attributes_for :intake, :wants_to_itemize

  def save
    @intake.update(attributes_for(:intake))
  end
end