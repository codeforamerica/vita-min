class LifeSituationsForm < QuestionsForm
  set_attributes_for :intake, :was_full_time_student, :was_on_visa, :had_disability, :was_blind

  def save
    @intake.update(attributes_for(:intake))
  end
end