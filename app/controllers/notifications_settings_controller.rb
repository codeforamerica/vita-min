class NotificationsSettingsController < ApplicationController

  def unsubscribe_from_emails
    matching_intakes = matching_intakes(params[:email_address])

    if matching_intakes.present?
      matching_intakes.each do |intake|
        intake.update(email_notification_opt_in: "no")
      end
    else
      flash[:alert] = "No record found"
    end
  end

  def subscribe_to_emails
    matching_intakes = matching_intakes(params[:email_address])

    if matching_intakes.present?
      matching_intakes.each do |intake|
        intake.update(email_notification_opt_in: "yes")
      end

      flash[:notice] = I18n.t("notifications_settings.subscribe_to_emails.flash")
      render :unsubscribe_from_emails
    else
      flash[:alert] = "No record found"
    end
  end

  private


  def matching_intakes(email_address)
    return if email_address.blank?
    email_address = Intake.signed_id_verifier.verified email_address
    Intake.where(email_address: email_address)
  rescue
    Rails.logger.error("invalid_signature: #{email_address}")
    nil
  end

end