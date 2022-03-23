class SpouseLifeSituationsForm < QuestionsForm
  set_attributes_for :intake, :spouse_was_full_time_student, :spouse_was_on_visa, :spouse_had_disability, :spouse_was_blind
  set_attributes_for :confirmation, :no_life_situations_apply
  validates :no_life_situations_apply, at_least_one_or_none_of_the_above_selected: true

  def save
    @intake.update(attributes_for(:intake))
  end

  def at_least_one_selected
    spouse_was_full_time_student == "yes" ||
      spouse_was_on_visa == "yes" ||
      spouse_had_disability == "yes" ||
      spouse_was_blind == "yes"
  end
end