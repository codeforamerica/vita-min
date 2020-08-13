class EipEligibilityForm < QuestionsForm
  set_attributes_for :intake, :claimed_by_another, :already_applied_for_stimulus, :no_ssn

  def save
    @intake.update(attributes_for(:intake))
  end
end