module StateFile
  class SendDfTransferIssueMessageService
    # assuming a data structure that looks like this:
    # [
    #   {
    #     email: false,
    #     sms: true,
    #     contact_info: "5551112222",
    #     state_code: "az"
    #   }
    # ]
    # and that the client verified and opted in to each of these contact methods
    def self.run(contact_list)
      contact_list.each_with_index do |contact, i|
        puts "."
        if !StateFile::StateInformationService.active_state_codes.include?(state_code)
          puts "state code missing or invalid; index #{i}; #{contact.contact_info}"
          return
        end
        if contact.contact_info.blank?
          puts "no contact info; index #{i}; #{state_code}"
          return
        end
        if !contact.email && !contact.sms
          puts "no contact method; index #{i}; #{contact.contact_info} #{contact.state_code}"
          return
        end
        SendReminderApologyMessageJob.perform_later(
          email: contact.email,
          sms: contact.sms,
          contact_info: contact.contact_info,
          state_code: contact.state_code
        )
      end
    end
  end
end

