module AutomatedMessage
  class SecondNotReadyReminder < FirstNotReadyReminder
    def self.name
      'messages.not_ready_second_reminder'.freeze
    end
  end
end
