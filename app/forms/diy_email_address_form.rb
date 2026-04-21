class DiyEmailAddressForm < DiyForm
  include FormAttributes
  attr_accessor :diy_intake
  set_attributes_for :diy_intake, :email_address
  set_attributes_for :confirmation, :email_address_confirmation

  validates :email_address, presence: true, 'valid_email_2/email': { mx: true }
  validates :email_address, confirmation: true
  validates :email_address_confirmation, presence: true
end
