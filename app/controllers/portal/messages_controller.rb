module Portal
  class MessagesController < PortalController
    def new
      @message = current_client.incoming_portal_messages.new
      @contact_methods = ClientMessagingService.contact_methods(current_client)
    end

    def create
      @message = current_client.incoming_portal_messages.new(form_params)
      if @message.save
        message = "#{I18n.t("portal.messages.create.message_sent")} #{helpers.client_contact_preference(current_client, no_tags: true)}"
        flash[:notice] = message
        redirect_to portal_root_path
      else
        flash[:alert] = I18n.t("general.error.form_failed")
        render :new
      end
    end

    def form_params
      params.require(:incoming_portal_message).permit(:body)
    end
  end
end