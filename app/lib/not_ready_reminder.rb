class NotReadyReminder
  def self.process(tax_return)
    return unless tax_return.status == "intake_in_progress"

    client = tax_return.client
    action = nil
    if tax_return.updated_at.beginning_of_day <= 9.days.ago.beginning_of_day
      action = "changed_status"
      tax_return.update(status: "file_not_filing")
    elsif tax_return.updated_at.beginning_of_day <= 6.days.ago.beginning_of_day
      message = AutomatedMessage::SecondNotReadyReminder
      unless MessageTracker.new(client: client, message: message).already_sent?
        action = message.name
        SendAutomatedMessage.new(client: client, message: message).send_messages
      end
    elsif tax_return.updated_at.beginning_of_day <= 3.days.ago.beginning_of_day
      message = AutomatedMessage::FirstNotReadyReminder
      unless MessageTracker.new(client: client, message: message).already_sent?
        action = message.name
        SendAutomatedMessage.new(client: client, message: message).send_messages
      end
    end
    action
  end
end