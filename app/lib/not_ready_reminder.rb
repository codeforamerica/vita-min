class NotReadyReminder
  def self.process(tax_return)
    return unless tax_return.status == "intake_in_progress"

    client = tax_return.client
    message = AutomatedMessage::NotReadyReminder.new
    action = nil
    if tax_return.updated_at.beginning_of_day <= 9.days.ago.beginning_of_day
      action = "changed_status"
      tax_return.update(status: "file_not_filing")
    elsif tax_return.updated_at.beginning_of_day <= 6.days.ago.beginning_of_day
      message_name = "messages.not_ready_second_reminder"
      unless MessageTracker.new(client: client, message_name: message_name).already_sent?
        action = message_name
        SendAutomatedMessage.new(client: client, message_name: message_name, message: message).send_messages
      end
    elsif tax_return.updated_at.beginning_of_day <= 3.days.ago.beginning_of_day
      message_name = "messages.not_ready_first_reminder"
      unless MessageTracker.new(client: client, message_name: message_name).already_sent?
        action = message_name
        SendAutomatedMessage.new(client: client, message_name: message_name, message: message).send_messages
      end
    end
    action
  end
end