class EstimatedTaxPaymentsForm < QuestionsForm
  set_attributes_for :intake, :made_estimated_tax_payments

  def save
    @intake.update(attributes_for(:intake))
  end
end