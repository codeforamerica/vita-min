class LivedWithSpouseForm < QuestionsForm
  set_attributes_for :intake, :lived_apart_from_spouse_last_6_months

  def save
    @intake.update(attributes_for(:intake))
  end
end
