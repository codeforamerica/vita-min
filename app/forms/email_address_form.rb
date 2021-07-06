class EmailAddressForm < QuestionsForm
  set_attributes_for :intake, :email_address
  set_attributes_for :confirmation, :email_address_confirmation

  validates :email_address, 'valid_email_2/email': true
  validates :email_address, confirmation: true
  validates :email_address_confirmation, presence: true

  def save
    @intake.update(attributes_for(:intake))
  end
end
