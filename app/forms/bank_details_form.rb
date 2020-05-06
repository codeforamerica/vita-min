class BankDetailsForm < QuestionsForm
  set_attributes_for :intake, :bank_name, :bank_routing_number, :bank_account_number, :bank_account_type

  def save
    attributes = attributes_for(:intake)
    attributes[:bank_account_type] = "unspecified" if bank_account_type.blank?
    @intake.update(attributes)
  end
end
