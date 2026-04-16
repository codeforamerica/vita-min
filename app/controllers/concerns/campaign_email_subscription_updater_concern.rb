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
        return render :unsubscribe_from_campaign_emails
      end

      unsub_timestamp = opt_in ? nil : Time.current

      contact.update!(
        email_notification_opt_in: opt_in,
        email_unsubscribed_at: unsub_timestamp
      )

      unless opt_in
        # log most recent email at time of unsubscribe
        last_email = contact.emails.order(created_at: :desc)&.first
        email_identifier = last_email&.message_name.presence ||
          last_email&.subject.presence ||
          "unknown_email"
        Datadog.statsd.increment('email.unsubscribes.count', tags: [
          "last_email:#{email_identifier.parameterize.underscore}",
          "email_type:campaign"
        ])
      end

      flash[:notice] = if opt_in
                         I18n.t("notifications_settings.campaign_messages.subscribe_to_emails.flash")
                       else
                         I18n.t("notifications_settings.campaign_messages.unsubscribe_from_emails.flash")
                       end

      render :unsubscribe_from_campaign_emails
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      flash[:alert] = I18n.t("notifications_settings.invalid_link")
      render :unsubscribe_from_campaign_emails
    end
  end
end
