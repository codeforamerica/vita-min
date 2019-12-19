class ScholarshipsForm < QuestionsForm
  set_attributes_for :intake, :has_scholarship_income

  def save
    @intake.update(attributes_for(:intake))
  end
end