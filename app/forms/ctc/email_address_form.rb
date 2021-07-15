module Ctc
  class EmailAddressForm < QuestionsForm
    set_attributes_for :intake, :email_address
    set_attributes_for :confirmation, :email_address_confirmation

    validates :email_address, 'valid_email_2/email': true
    validates :email_address, confirmation: true
    validates :email_address_confirmation, presence: true

    def save
      attributes = attributes_for(:intake).merge(email_notification_opt_in: "yes")
      attributes[:email_address_verified_at] = nil if @intake.email_address != email_address
      @intake.update(attributes)
    end
  end
end