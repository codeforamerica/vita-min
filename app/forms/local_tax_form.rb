class LocalTaxForm < QuestionsForm
  set_attributes_for :intake, :paid_local_tax

  def save
    @intake.update(attributes_for(:intake))
  end
end