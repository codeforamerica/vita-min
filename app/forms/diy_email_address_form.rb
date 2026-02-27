class DiyEmailAddressForm < Form
  include FormAttributes
  attr_accessor :diy_intake
  set_attributes_for :diy_intake, :email_address
  set_attributes_for :confirmation, :email_address_confirmation

  validates :email_address, presence: true, 'valid_email_2/email': { mx: true }
  validates :email_address, confirmation: true
  validates :email_address_confirmation, presence: true

  def initialize(diy_intake = nil, params = {})
    @diy_intake = diy_intake
    super(params)
  end

  def save
    diy_intake.update!(attributes_for(:diy_intake))
  end

  def self.existing_attributes(diy_intake)
    HashWithIndifferentAccess.new(diy_intake.attributes)
  end
end
