class AlreadyFiledForm < QuestionsForm
  set_attributes_for :intake, :already_filed, :source, :referrer

  def save
    @intake.update(attributes_for(:intake))
  end
end
