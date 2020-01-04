class AdditionalInfoForm < QuestionsForm
  set_attributes_for :intake, :additional_info

  def save
    @intake.update(attributes_for(:intake))
  end
end