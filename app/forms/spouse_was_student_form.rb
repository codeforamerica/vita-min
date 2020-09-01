class SpouseWasStudentForm < QuestionsForm
  set_attributes_for :intake, :spouse_was_full_time_student

  def save
    @intake.update(attributes_for(:intake))
  end
end