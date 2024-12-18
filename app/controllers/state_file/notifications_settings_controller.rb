module StateFile
  class NotificationsSettingsController < ApplicationController
    layout "state_file"
    include EmailSubscriptionUpdaterConcern

    def unsubscribe_from_emails
      update_email_subscription(direction: true, column_name: :unsubscribed_from_email)
    end

    def subscribe_to_emails
      update_email_subscription(direction: false, column_name: :unsubscribed_from_email, show_flash_and_render: true)
    end

    private

    def matching_intakes(email_address)
      return if email_address.blank?

      StateFile::StateInformationService.state_intake_classes.map { |klass| klass.where(email_address: email_address) }.inject([], :+)
    end
  end
end
