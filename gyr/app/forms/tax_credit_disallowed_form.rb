class TaxCreditDisallowedForm < QuestionsForm
  set_attributes_for :intake, :had_tax_credit_disallowed

  def save
    @intake.update(attributes_for(:intake))
  end
end