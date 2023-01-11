class SpouseLifeSituationsForm < QuestionsForm
  set_attributes_for :intake, :spouse_was_full_time_student, :spouse_not_us_citizen, :spouse_had_disability, :spouse_was_blind
  set_attributes_for :confirmation, :no_life_situations_apply
  validates :no_life_situations_apply, at_least_one_or_none_of_the_above_selected: true
  def at_least_one_selected
    spouse_was_full_time_student == "yes" ||
      spouse_not_us_citizen == "yes" ||
      spouse_had_disability == "yes" ||
      spouse_was_blind == "yes"
  end

  def self.existing_attributes(intake)
    result = super
    result[:spouse_not_us_citizen] = result.delete(:spouse_us_citizen) == 'no' ? 'yes' : 'no'
    result
  end

  def save
    modified_attributes = attributes_for(:intake)
    modified_attributes[:spouse_us_citizen] = modified_attributes.delete(:spouse_not_us_citizen) == "yes" ? "no" : "yes"

    @intake.update(modified_attributes)
  end
end