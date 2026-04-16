module EmailSubscriptionUpdaterConcern
  extend ActiveSupport::Concern

  def update_email_subscription(direction:, column_name:, show_flash_and_render: false)
    verifier = ActiveSupport::MessageVerifier.new(Rails.application.secret_key_base)

    if params[:email_address].blank?
      flash[:alert] = I18n.t("notifications_settings.no_record")
      return
    end

    begin
      email_address = verifier.verify(params[:email_address])
      matching_intakes = matching_intakes(email_address)

      if matching_intakes.present?
        unsub_timestamp = (direction == "no") ? Time.current : nil

        matching_intakes.each do |intake|
          intake.update(
            column_name => direction,
            email_unsubscribed_at: unsub_timestamp
          )

          if direction == "no"
            # log most recent email at time of unsubscribe
            last_email = intake.client.outgoing_emails.order(created_at: :desc)&.first
            email_identifier = last_email&.subject || "unknown_email"
            Datadog.statsd.increment('email.unsubscribes.count', tags: ["last_email:#{email_identifier.parameterize}"])
          end
        end

        if show_flash_and_render
          flash[:notice] = I18n.t("notifications_settings.subscribe_to_emails.flash")
          render :unsubscribe_from_emails
        end
      else
        flash[:alert] = I18n.t("notifications_settings.no_record")
      end
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      flash[:alert] = I18n.t("notifications_settings.invalid_link")
    end
  end
end

