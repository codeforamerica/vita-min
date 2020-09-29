class OutgoingTextMessagesController < ApplicationController
  include AccessControllable

  before_action :require_sign_in, :require_beta_tester

  def create
    message = OutgoingTextMessage.new(outgoing_text_message_params)
    if message.save
      SendOutgoingTextMessageJob.perform_later(message.id)
    end
    redirect_to client_messages_path(client_id: outgoing_text_message_params[:client_id])
  end

  private

  def outgoing_text_message_params
    params.require(:outgoing_text_message).permit(:client_id, :body).merge(
      sent_at: DateTime.now, user: current_user
    )
  end
end
