class SendReminderApologyMessageJob < ApplicationJob
  def perform(intake)
    StateFile::MessagingService.new(
      message: StateFile::AutomatedMessage::ReminderApology,
      intake: intake
    ).send_message
  end

  def priority
    PRIORITY_MEDIUM
  end
end
