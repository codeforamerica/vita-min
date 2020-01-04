class StudentForm < QuestionsForm
  set_attributes_for :intake, :had_student_in_family

  def save
    @intake.update(attributes_for(:intake))
  end
end