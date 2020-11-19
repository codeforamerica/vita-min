module CaseManagement
  class OutgoingTextMessagesController < ApplicationController
    include AccessControllable
    include MessageSending

    before_action :require_sign_in
    load_and_authorize_resource :client
    load_and_authorize_resource through: :client

    def create
      if outgoing_text_message_params[:body].present?
        send_text_message(outgoing_text_message_params[:body])
      end
      redirect_to case_management_client_messages_path(client_id: @client.id)
    end

    private

    def outgoing_text_message_params
      params.require(:outgoing_text_message).permit(:body)
    end
  end
end
