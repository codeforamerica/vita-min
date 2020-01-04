class RentalIncomeForm < QuestionsForm
  set_attributes_for :intake, :had_rental_income

  def save
    @intake.update(attributes_for(:intake))
  end
end