class MarriedForm < QuestionsForm
  set_attributes_for :intake, :married, :married_last_day_of_year

  def save
    status = attributes_for(:intake)[:married]
    @intake.update(married: status,
                   married_last_day_of_year: status)
  end
end
