class ClientsController < ApplicationController
  include ZendeskAuthenticationControllerHelper

  before_action :require_zendesk_admin

  layout "admin"

  def create
    intake = Intake.find_by(id: params[:intake_id])
    return head 422 unless intake.present?

    client = Client.create_from_intake(intake)
    redirect_to client_path(id: client.id)
  end

  def show
    @client = Client.find(params[:id])
    @contact_history = (@client.outgoing_text_messages + @client.incoming_text_messages).sort_by(&:datetime)
  end

  def send_text
    outgoing_text_message = OutgoingTextMessage.create(
      client: Client.find(params[:client_id]),
      body: params[:body],
      sent_at: DateTime.now,
      user: current_user,
    )
    SendOutgoingTextMessageJob.perform_later(outgoing_text_message.id)
    redirect_to client_path(id: params[:client_id])
  end

  def text_status_callback
    id = ActiveSupport::MessageVerifier.new(EnvironmentCredentials.dig(:secret_key_base)).verified(
      params[:verifiable_outgoing_text_message_id], purpose: :twilio_text_message_status_callback
    )
    return if id.blank?

    OutgoingTextMessage.find(id).update(twilio_status: params[:MessageStatus])
  end
end
