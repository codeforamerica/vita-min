module Portal
  class MessagesController < PortalController
    def new
      @message = current_client.incoming_portal_messages.new
      @contact_methods = ClientMessagingService.contact_methods(current_client)
    end

    def create
      @message = current_client.incoming_portal_messages.new(form_params)
      if @message.save
        flash_message = "#{I18n.t("portal.messages.create.message_sent")} #{helpers.client_contact_preference(current_client, no_tags: true)}"
        flash[:notice] = flash_message
        TransitionNotFilingService.run(current_client)
        portal_message = @message
        client = portal_message.client
        if current_client.forward_message_to_intercom?
          IntercomService.create_message(
            client: client,
            body: portal_message.body,
            email_address: client.intake.email_address,
            phone_number: client.intake.sms_phone_number,
            has_documents: false
          )
          IntercomService.inform_client_of_handoff(client: client, send_email: client.intake.email_address.present?, send_sms: client.intake.sms_phone_number.present?)
        end
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