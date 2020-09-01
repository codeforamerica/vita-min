class SpouseLifeSituationsForm < QuestionsForm
  set_attributes_for :intake, :spouse_was_full_time_student, :spouse_was_on_visa, :spouse_had_disability, :spouse_was_blind

  def save
    @intake.update(attributes_for(:intake))
  end
end