module Hub
  class OutgoingTextMessagesController < ApplicationController
    include AccessControllable

    before_action :require_sign_in
    load_and_authorize_resource :client
    load_and_authorize_resource through: :client

    def create
      if outgoing_text_message_params[:body].present?
        ClientMessagingService.send_text_message(@client, current_user, outgoing_text_message_params[:body])
      end
      redirect_to hub_client_messages_path(client_id: @client.id)
    end

    private

    def outgoing_text_message_params
      params.require(:outgoing_text_message).permit(:body)
    end
  end
end
