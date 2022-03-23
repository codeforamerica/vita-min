class LifeSituationsForm < QuestionsForm
  set_attributes_for :intake, :was_full_time_student, :was_on_visa, :had_disability, :was_blind
  set_attributes_for :confirmation, :no_life_situations_apply
  validates :no_life_situations_apply, at_least_one_or_none_of_the_above_selected: true

  def save
    @intake.update(attributes_for(:intake))
  end

  def at_least_one_selected
    was_full_time_student == "yes" ||
      was_on_visa == "yes" ||
      had_disability == "yes" ||
      was_blind == "yes"
  end
end