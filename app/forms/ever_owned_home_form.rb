class EverOwnedHomeForm < QuestionsForm
  set_attributes_for :intake, :ever_owned_home

  def save
    @intake.update(attributes_for(:intake))
  end
end