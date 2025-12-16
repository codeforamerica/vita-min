class ClaimingForm < QuestionsForm
  set_attributes_for :intake, :claimed_by_another

  def save
    @intake.update(attributes_for(:intake))
  end
end