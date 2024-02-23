class SendIssueResolvedMessageJob < ApplicationJob
  include Rails.application.routes.url_helpers

  def perform(intakes)
    intakes.each do |intake|
      send_message(intake)
    end
  end

  def send_message(intake)
    return unless %w[StateFileAzIntake StateFileNyIntake].include?(intake.class.name)

    message = StateFile::MessagingService.new(
      intake: intake,
      message: StateFile::AutomatedMessage::IssueResolved,
      body_args: { login_link: login_link }).send_message

    Rails.logger.error("*********No message sent for #{intake.class.name} ##{intake.id}") unless message
    Rails.logger.info("*********StateFileNotificationEmail ##{message.first.id} created") if message.present?
  end

  def priority
    PRIORITY_LOW
  end

  private

  def login_link
    url_for(host: MultiTenantService.new(:statefile).host, controller: "state_file/state_file_pages", action: "login_options", us_state: "us")
  end
end