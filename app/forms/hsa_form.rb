class HsaForm < QuestionsForm
  set_attributes_for :intake, :had_hsa

  def save
    @intake.update(attributes_for(:intake))
  end
end