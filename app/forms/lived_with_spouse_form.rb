class LivedWithSpouseForm < QuestionsForm
  set_attributes_for :intake, :lived_with_spouse

  def save
    @intake.update(attributes_for(:intake))
  end
end