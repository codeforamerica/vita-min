module AutomatedMessage
  class SecondNotReadyReminder < FirstNotReadyReminder

    def self.require_client_account?
      true
    end

    def self.name
      'messages.not_ready_second_reminder'.freeze
    end
  end
end
