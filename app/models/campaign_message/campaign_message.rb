module CampaignMessage
  class CampaignMessage
    def vars(contact)
      {
        first_name: contact&.first_name || "",
        last_name: contact&.last_name || "",
        locale: contact&.locale || :en,
      }
    end

    def self.msg_for_name(message_name)
      klass = "CampaignMessage::#{message_name.camelize}".safe_constantize
      raise ArgumentError, "Unknown message_name: #{message_name}" unless klass
      klass.new
    end

    def self.valid_msg_name?(message_name) # redundant
      "CampaignMessage::#{message_name.camelize}".safe_constantize.present?
    end

    def self.max_sends_per_contact
      1
    end
  end
end