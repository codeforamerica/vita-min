class EverMarriedForm < QuestionsForm
  set_attributes_for :intake, :ever_married

  def save
    @intake.update(attributes_for(:intake))
  end
end