class SendClientSaveCtcLetterMessageJob < ApplicationJob
  def perform(number_of_clients: 0)
    total_sent = 0

    puts "\n==Sending messages to #{number_of_clients} clients=="
    Archived::Intake2021.limit(number_of_clients).find_each do |intake|
      message_tracker = MessageTracker.new(client: intake.client, message: AutomatedMessage::SaveCtcLetter)
      next if message_tracker.already_sent?

      messages = send_message(intake)
      puts "Client ##{intake.client.id} sent messages: #{messages}" if messages.present?
      total_sent += 1 if messages.count
    end

    puts "==Sent #{total_sent} messages=="
  end

  private

  def send_message(intake)
    return if intake.email_notification_opt_in != "yes" && intake.sms_notification_opt_in != "yes"

    service_name = intake.is_ctc? ? MultiTenantService.new(:ctc).service_name : MultiTenantService.new(:gyr).service_name

    ClientMessagingService.send_system_message_to_all_opted_in_contact_methods(
      client: intake.client,
      message: AutomatedMessage::SaveCtcLetter,
      tax_return: nil,
      locale: intake.locale,
      body_args: { service_name: service_name }
    )
  end
end