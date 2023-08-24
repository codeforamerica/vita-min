class MarriedForm < QuestionsForm
  set_attributes_for :intake, :married

  def save
    @intake.update(attributes_for(:intake))
  end
end