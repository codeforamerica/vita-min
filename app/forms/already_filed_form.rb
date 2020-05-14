class AlreadyFiledForm < QuestionsForm
  set_attributes_for :intake, :already_filed

  def save
    @intake.update(attributes_for(:intake))
  end

end
