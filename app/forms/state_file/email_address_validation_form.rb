module StateFile
  class EmailAddressValidationForm < QuestionsForm
    set_attributes_for :state_file_archived_intake_access_logs, :ip_address, :event_type, :updated_at
    def save
      @intake.update(attributes_for(:state_file_archived_intake_access_logs))
    end
  end
end