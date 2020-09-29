class MessagesController < ApplicationController
  include AccessControllable

  before_action :require_sign_in, :require_beta_tester

  layout "admin"

  def index
    @client = Client.find(params[:client_id])
    @contact_history = (
      @client.outgoing_text_messages.includes(:user) +
      @client.incoming_text_messages +
      @client.outgoing_emails.includes(:user) +
      @client.incoming_emails
    ).sort_by(&:datetime)
    @outgoing_text_message = OutgoingTextMessage.new(client: @client)
    @outgoing_email = OutgoingEmail.new(client: @client)
  end
end