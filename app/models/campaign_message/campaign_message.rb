module CampaignMessage
  class CampaignMessage
    def vars(contact)
      {
        first_name: contact&.first_name || "",
        last_name: contact&.last_name || "",
        locale: contact&.locale || :en,
      }
    end

    def self.max_sends_per_contact
      1
    end
  end
end