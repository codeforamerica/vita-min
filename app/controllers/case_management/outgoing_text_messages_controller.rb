module CaseManagement
  class OutgoingTextMessagesController < ApplicationController
    include AccessControllable

    before_action :require_sign_in
    load_and_authorize_resource :client
    load_and_authorize_resource through: :client

    def create
      @outgoing_text_message.to_phone_number = @outgoing_text_message.client.sms_phone_number
      if @outgoing_text_message.save
        SendOutgoingTextMessageJob.perform_later(@outgoing_text_message.id)
      end
      redirect_to case_management_client_messages_path(client_id: @client.id)
    end

    private

    def outgoing_text_message_params
      params.require(:outgoing_text_message).permit(:body).merge(
        sent_at: DateTime.now, user: current_user, client: @client
      )
    end
  end
end
