module CaseManagement
  class OutgoingEmailsController < ApplicationController
    include AccessControllable
    include MessageSending

    before_action :require_sign_in
    load_and_authorize_resource :client
    load_and_authorize_resource through: :client

    def create
      if outgoing_email_params[:body].present?
        send_email(@client, body: outgoing_email_params[:body], attachment: outgoing_email_params[:attachment])
      end
      redirect_to case_management_client_messages_path(client_id: @outgoing_email.client_id)
    end

    private

    def outgoing_email_params
      # Use client locale someday
      params.require(:outgoing_email).permit(:body, :attachment)
    end
  end
end
