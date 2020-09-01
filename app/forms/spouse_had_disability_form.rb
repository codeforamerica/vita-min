class SpouseHadDisabilityForm < QuestionsForm
  set_attributes_for :intake, :spouse_had_disability

  def save
    @intake.update(attributes_for(:intake))
  end
end