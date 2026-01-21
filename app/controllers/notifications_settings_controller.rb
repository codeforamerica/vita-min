class NotificationsSettingsController < ApplicationController
  include EmailSubscriptionUpdaterConcern
  include CampaignEmailSubscriptionUpdaterConcern

  def unsubscribe_from_emails
    update_email_subscription(direction: "no", column_name: :email_notification_opt_in)
  end

  def subscribe_to_emails
    update_email_subscription(direction: "yes", column_name: :email_notification_opt_in, show_flash_and_render: true)
  end

  def unsubscribe_from_campaign_emails
    update_campaign_contact_email_opt_in(opt_in: false)
  end

  def subscribe_to_campaign_emails
    update_campaign_contact_email_opt_in(opt_in: true)
  end

  private

  def matching_intakes(email_address)
    return if email_address.blank?

    Intake.where(email_address: email_address)
  end
end