class SpouseEmailAddressForm < QuestionsForm
  set_attributes_for :intake, :spouse_email_address, :spouse_email_address_confirmation
  validates :spouse_email_address, 'valid_email_2/email': true
  validates :spouse_email_address, confirmation: true
  validates :spouse_email_address_confirmation, presence: true

  def save
    @intake.update(attributes_for(:intake).except(:spouse_email_address_confirmation))
  end
end
