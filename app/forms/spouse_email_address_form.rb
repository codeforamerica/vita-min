class SpouseEmailAddressForm < QuestionsForm
  set_attributes_for :intake, :spouse_email_address, :spouse_email_address_confirmation
  validates :spouse_email_address, format: {
    with: URI::MailTo::EMAIL_REGEXP,
    message: "Please enter a valid email address.",
  }
  validates :spouse_email_address, confirmation: { message: "Please double check that the email addresses match." }
  validates :spouse_email_address_confirmation, presence: true

  def save
    @intake.update(attributes_for(:intake).except(:spouse_email_address_confirmation))
  end
end
