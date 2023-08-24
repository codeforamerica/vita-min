class AdoptedChildForm < QuestionsForm
  set_attributes_for :intake, :adopted_child

  def save
    @intake.update(attributes_for(:intake))
  end
end