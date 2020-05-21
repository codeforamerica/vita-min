class DiyEmailAddressForm < DiyForm
  set_attributes_for :diy_intake, :email_address, :email_address_confirmation

  validates :email_address, 'valid_email_2/email': { message: "Please enter a valid email address." }
  validates :email_address, confirmation: { message: "Please double check that the email addresses match." }
  validates :email_address_confirmation, presence: true

  def save
    @diy_intake.update(attributes_for(:diy_intake).except(:email_address_confirmation))
  end
end
