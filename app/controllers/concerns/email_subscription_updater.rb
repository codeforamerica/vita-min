module EmailSubscriptionUpdater
  extend ActiveSupport::Concern

  def update_email_subscription(direction:, column_name:, show_flash_and_render: false)
    verifier = ActiveSupport::MessageVerifier.new(Rails.application.secret_key_base)

    if params[:email_address].blank?
      flash[:alert] = "No record found"
      return
    end

    begin
      email_address = verifier.verify(params[:email_address])
      matching_intakes = matching_intakes(email_address)

      if matching_intakes.present?
        matching_intakes.each do |intake|
          intake.update(column_name => direction)
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

