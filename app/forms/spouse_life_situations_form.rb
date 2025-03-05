class SpouseLifeSituationsForm < QuestionsForm
  set_attributes_for :intake, :spouse_was_full_time_student, :spouse_us_citizen, :spouse_visa, :spouse_had_disability, :spouse_was_blind
  set_attributes_for :confirmation, :no_life_situations_apply

  def save
    modified_attributes = attributes_for(:intake)

    @intake.update(modified_attributes)
  end
end
