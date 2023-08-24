class OtherStatesForm < QuestionsForm
  set_attributes_for :intake, :multiple_states

  def save
    @intake.update(attributes_for(:intake))
  end
end