class OutgoingTextMessagesController < ApplicationController
  before_action :redirect_to_client_unless_admin

  def create
    message = OutgoingTextMessage.new(outgoing_text_message_params)
    if message.save
      SendOutgoingTextMessageJob.perform_later(message.id)
    end
    redirect_to client_path(id: outgoing_text_message_params[:client_id])
  end

  private

  def outgoing_text_message_params
    params.require(:outgoing_text_message).permit(:client_id, :body).merge(
      sent_at: DateTime.now, user: current_user
    )
  end

  def redirect_to_client_unless_admin
    redirect_to client_path(id: outgoing_text_message_params[:client_id]) unless current_user&.role == "admin"
  end
end
