class LifeSituationsForm < QuestionsForm
  set_attributes_for :intake, :was_full_time_student, :primary_us_citizen, :primary_visa, :had_disability, :was_blind
  set_attributes_for :confirmation, :no_life_situations_apply

  def save
    modified_attributes = attributes_for(:intake)

    @intake.update(modified_attributes)
  end
end
