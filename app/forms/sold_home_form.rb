class SoldHomeForm < QuestionsForm
  set_attributes_for :intake, :sold_a_home

  def save
    @intake.update(attributes_for(:intake))
  end
end