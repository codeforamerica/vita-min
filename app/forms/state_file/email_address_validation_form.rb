module StateFile
  class EmailAddressValidationForm < QuestionsForm
    set_attributes_for :intake, :email_address

    validates :email_address, 'valid_email_2/email': true
    validates :email_address, presence: true
  end
end