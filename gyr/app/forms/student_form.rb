class StudentForm < QuestionsForm
  set_attributes_for :intake, :paid_post_secondary_educational_expenses

  def save
    @intake.update(attributes_for(:intake))
  end
end