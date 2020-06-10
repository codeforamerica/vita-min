class AlreadyFiledForm < QuestionsForm
  set_attributes_for :intake, :already_filed, :source, :referrer, :locale

  def save
    @intake.update(attributes_for(:intake))
  end
end
