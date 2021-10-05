module AutomatedMessage
  class AutomatedMessage

    # indicate that you want to track sending and block duplicates from being sent.
    def self.send_only_once?
      false
    end
  end
end