module Hub
  class OutgoingEmailsController < Hub::BaseController
    load_and_authorize_resource :client

    def create
      if outgoing_email_params[:body].present?
        ClientMessagingService.send_email(
          client: @client,
          user: current_user,
          body: outgoing_email_params[:body],
          attachment: outgoing_email_params[:attachment]
        )
      end
      redirect_to hub_client_messages_path(client_id: @client, anchor: "last-item")
    end

    def unsubscribe_email
      matching_intakes = matching_intakes(params[:email_address])

      if matching_intakes.present?
        matching_intakes.each do |intake|
          intake.update(email_notification_opt_in: 2)
        end
      else
        flash[:alert] = "No record found"
      end
    end

    def subscribe_email
      matching_intakes = matching_intakes(params[:email_address])

      if matching_intakes.present?
        matching_intakes.each do |intake|
          intake.update(email_notification_opt_in: 1)
        end

        flash[:notice] = I18n.t("state_file.notifications_settings.subscribe_email.flash")
        render :unsubscribe_email
      else
        flash[:alert] = "No record found"
      end
    end

    private

    def outgoing_email_params
      params.require(:outgoing_email).permit(:body, :attachment)
    end

    def matching_intakes(email_address)
      return if email_address.blank?

      @client.intake.where(email_address: email_address)
    end
  end
end
