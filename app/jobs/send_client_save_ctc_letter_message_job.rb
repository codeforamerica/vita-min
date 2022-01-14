class SendClientSaveCtcLetterMessageJob < ApplicationJob
  def perform(number_of_clients: 0)
    total_sent = 0

    Archived::Intake2021.all.limit(number_of_clients).find_each do |intake|
      next if MessageTracker.new(client: intake.client, message: AutomatedMessage::SaveCtcLetter).already_sent?

      messages = send_message(intake)
      puts "Sent message to #{intake.client.id}" if messages.present?
      total_sent += 1 if messages.present?
    end

    puts "***Sent #{total_sent} messages"
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