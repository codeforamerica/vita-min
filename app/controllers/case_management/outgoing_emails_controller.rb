module CaseManagement
  class OutgoingEmailsController < ApplicationController
    include AccessControllable

    before_action :require_sign_in
    load_and_authorize_resource :client
    load_and_authorize_resource through: :client

    def create
      @outgoing_email.to = @outgoing_email.client.email_address
      if @outgoing_email.save
        OutgoingEmailMailer.user_message(outgoing_email: @outgoing_email).deliver_later
      end
      redirect_to case_management_client_messages_path(client_id: @outgoing_email.client_id)
    end

    private

    def outgoing_email_params
      # Use client locale someday
      params.require(:outgoing_email).permit(:body, :attachment).merge(
        subject: I18n.t("email.user_message.subject", locale: "en"),
        sent_at: DateTime.now,
        client: @client,
        user: current_user
      )
    end
  end
end
