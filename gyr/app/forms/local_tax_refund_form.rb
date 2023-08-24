class LocalTaxRefundForm < QuestionsForm
  set_attributes_for :intake, :had_local_tax_refund

  def save
    @intake.update(attributes_for(:intake))
  end
end