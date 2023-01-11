class LifeSituationsForm < QuestionsForm
  set_attributes_for :intake, :was_full_time_student, :primary_not_us_citizen, :had_disability, :was_blind
  set_attributes_for :confirmation, :no_life_situations_apply
  validates :no_life_situations_apply, at_least_one_or_none_of_the_above_selected: true

  def at_least_one_selected
    was_full_time_student == "yes" ||
      primary_not_us_citizen == "yes" ||
      had_disability == "yes" ||
      was_blind == "yes"
  end

  def self.existing_attributes(intake)
    result = super
    result[:primary_not_us_citizen] = result.delete(:primary_us_citizen) == 'no' ? 'yes' : 'no'
    result
  end

  def save
    modified_attributes = attributes_for(:intake)
    modified_attributes[:primary_us_citizen] = modified_attributes.delete(:primary_not_us_citizen) == "yes" ? "no" : "yes"

    @intake.update(modified_attributes)
  end
end