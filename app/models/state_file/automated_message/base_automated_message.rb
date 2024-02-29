module StateFile::AutomatedMessage
  class BaseAutomatedMessage

    # indicate that you want to track sending and block duplicates from being sent.
    def self.send_only_once?
      false
    end

    def self.after_transition_notification?
      false
    end
  end
end