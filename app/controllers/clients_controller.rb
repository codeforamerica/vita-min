class ClientsController < ApplicationController
  include ZendeskAuthenticationControllerHelper

  # before_action :require_zendesk_admin

  layout "admin"

  def create
    intake = Intake.find_by(id: params[:intake_id])
    return head 422 unless intake.present?

    # Don't create additional clients if we already have one
    return redirect_to client_path(id: intake.client_id) if intake.client_id.present?

    client = Client.create_from_intake(intake)
    intake.update(client: client)
    redirect_to client_path(id: client.id)
  end

  def show
    @client = Client.find(params[:id])
    @contact_history = (
      @client.outgoing_text_messages.includes(:user) +
      @client.incoming_text_messages +
      @client.outgoing_emails.includes(:user) +
      @client.incoming_emails
    ).sort_by(&:datetime)
    @outgoing_text_message = OutgoingTextMessage.new(client: @client)
    @outgoing_email = OutgoingEmail.new(client: @client)
  end

  def self.broadcast_from_repl(user)
    WebNotificationsChannel.broadcast_to(
        user,
        title: 'New things!',
        body: 'All the news fit to print'
    )
  end
end
