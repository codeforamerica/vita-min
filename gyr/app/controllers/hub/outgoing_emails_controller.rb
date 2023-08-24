module Hub
  class OutgoingEmailsController < ApplicationController
    include AccessControllable

    before_action :require_sign_in
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

    private

    def outgoing_email_params
      params.require(:outgoing_email).permit(:body, :attachment)
    end
  end
end
