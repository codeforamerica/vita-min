class SendIssueResolvedMessageJob < ApplicationJob

  def perform(intakes)
    intakes.each do |intake|
      send_message(intake)
    end
  end

  def send_message(intake)
    return unless StateFile::StateInformationService.state_intake_classes.include?(intake.class)

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

  def self.login_link
    Rails.application.routes.url_for(host: MultiTenantService.new(:statefile).host, controller: "state_file/state_file_pages", action: "login_options", us_state: "us")
  end

  private

  def login_link
    self.class.login_link
  end
end