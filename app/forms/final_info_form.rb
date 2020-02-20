class FinalInfoForm < QuestionsForm
  set_attributes_for :intake, :final_info

  def save
    @intake.update(attributes_for(:intake))
  end
end