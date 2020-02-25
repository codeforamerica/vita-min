class EligibilityForm < QuestionsForm
  set_attributes_for :intake, :had_farm_income, :had_rental_income, :income_over_limit

  def save
    @intake.update(attributes_for(:intake))
  end
end