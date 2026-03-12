class DiyInitialInfoForm < DiyForm
  include FormAttributes
  attr_accessor :diy_intake
  set_attributes_for :diy_intake, :preferred_first_name, :state_of_residence, :zip_code

  validates :zip_code, zip_code: true, allow_blank: true
end
