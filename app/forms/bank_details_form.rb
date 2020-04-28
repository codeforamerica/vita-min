class BankDetailsForm < QuestionsForm
  set_attributes_for :intake, :bank_name, :bank_routing_number, :bank_account_number, :bank_account_type

  def save
    @intake.update(attributes_for(:intake))
  end
end
