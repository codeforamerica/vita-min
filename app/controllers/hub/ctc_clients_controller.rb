module Hub
  class CtcClientsController < Hub::BaseController
    load_and_authorize_resource :client, parent: false
    layout "hub"

    def edit
      return render "public_pages/page_not_found", status: 404 unless @client.intake.is_ctc?

      @is_dropoff = @client.tax_returns.any? { |tax_return| tax_return.service_type == "drop_off" }
      @form = UpdateCtcClientForm.from_client(@client)
    end

    def update
      @form = UpdateCtcClientForm.new(@client, update_client_form_params)

      if @form.valid? && @form.save
        SystemNote::ClientChange.generate!(initiated_by: current_user, intake: @client.intake)
        if @client.tax_returns.last.service_type_online_intake?
          send_email_change_notification if @client.intake.saved_change_to_email_address?
          send_sms_change_notification if @client.intake.saved_change_to_sms_phone_number?
        end
        redirect_to hub_client_path(id: @client.id)
      else
        flash[:alert] = I18n.t("forms.errors.general")
        @is_dropoff = @client.tax_returns.any? { |tax_return| tax_return.service_type == "drop_off" }
        render :edit
      end
    end

    private

    def update_client_form_params
      params.require(UpdateCtcClientForm.form_param).permit(UpdateCtcClientForm.permitted_params)
    end

    def send_email_change_notification
      message = AutomatedMessage::ContactInfoChange.new
      intake = @client.intake
      ClientMessagingService.send_system_email(client: @client, body: message.email_body, subject: message.email_subject, to: intake.email_address_before_last_save)
      ClientMessagingService.send_system_email(client: @client, body: message.email_body, subject: message.email_subject, to: intake.email_address)
    end

    def send_sms_change_notification
      message = AutomatedMessage::ContactInfoChange.new
      intake = @client.intake
      ClientMessagingService.send_system_text_message(client: @client, body: message.sms_body, to: intake.sms_phone_number_before_last_save)
      ClientMessagingService.send_system_text_message(client: @client, body: message.sms_body, to: intake.sms_phone_number)
    end
  end
end
