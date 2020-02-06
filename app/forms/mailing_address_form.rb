class MailingAddressForm < QuestionsForm
  set_attributes_for :intake, :street_address, :city, :state, :zip_code

  def save
    @intake.update(attributes_for(:intake))
  end
end
