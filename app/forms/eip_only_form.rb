class EipOnlyForm < QuestionsForm
  set_attributes_for :intake, :eip_only

  def save
    @intake.update(eip_only: true)
  end
end