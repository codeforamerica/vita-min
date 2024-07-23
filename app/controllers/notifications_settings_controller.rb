class NotificationsSettingsController < ApplicationController

  def unsubscribe_from_emails
    verifier = ActiveSupport::MessageVerifier.new(Rails.application.secret_key_base)

    begin
      email_address = verifier.verify(params[:email_address])
      matching_intakes = matching_intakes(email_address)

      if matching_intakes.present?
        matching_intakes.each do |intake|
          intake.update(email_notification_opt_in: "no")
        end
      else
        flash[:alert] = "No record found"
      end
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      flash[:alert] = "Invalid unsubscribe link"
    end
  end

  def subscribe_to_emails
    verifier = ActiveSupport::MessageVerifier.new(Rails.application.secret_key_base)

    begin
      email_address = verifier.verify(params[:email_address])
      matching_intakes = matching_intakes(email_address)

      if matching_intakes.present?
        matching_intakes.each do |intake|
          intake.update(email_notification_opt_in: "yes")
        end

        flash[:notice] = I18n.t("notifications_settings.subscribe_to_emails.flash")
        render :unsubscribe_from_emails
      else
        flash[:alert] = "No record found"
      end
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      flash[:alert] = "Invalid subscribe link"
    end
  end

  private


  def matching_intakes(email_address)
    return if email_address.blank?

    Intake.where(email_address: email_address)
  end

end