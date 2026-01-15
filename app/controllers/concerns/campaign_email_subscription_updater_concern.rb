module CampaignEmailSubscriptionUpdaterConcern
  extend ActiveSupport::Concern

  def update_campaign_contact_email_opt_in(opt_in:)
    verifier = ActiveSupport::MessageVerifier.new(Rails.application.secret_key_base)

    if params[:email_address].blank?
      flash[:alert] = I18n.t("notifications_settings.invalid_link")
      return render :campaign_email_preferences
    end

    begin
      email = verifier.verify(params[:email_address])

      contact = CampaignContact.find_by(email_address: email.to_s.strip)

      if contact.nil?
        flash[:alert] = I18n.t("notifications_settings.no_record")
        return render :campaign_email_preferences
      end

      contact.update!(email_notification_opt_in: opt_in)

      flash[:notice] = if opt_in
                         I18n.t("notifications_settings.campaign_messages.subscribe_to_emails.flash")
                       else
                         I18n.t("notifications_settings.campaign_messages.unsubscribe_from_emails.flash")
                       end

      render :campaign_email_preferences
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      flash[:alert] = I18n.t("notifications_settings.invalid_link")
      render :campaign_email_preferences
    end
  end
end
