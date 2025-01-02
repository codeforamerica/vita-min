module StateFile
  class EmailAddressValidationForm < QuestionsForm
    set_attributes_for :state_file_archived_intake, :email_address
    validates :email_address, 'valid_email_2/email': true
    validates :email_address, presence: true
    validates :email_address_attached_to_an_intake

    def save
      @intake.update(attributes_for(:state_file_archived_intake_access_logs))
    end


  end
end