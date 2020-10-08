module CaseManagement
  class ClientsController < ApplicationController
    include AccessControllable

    before_action :require_sign_in
    load_and_authorize_resource

    layout "admin"

    def index
      @clients = @clients.includes(intakes: :vita_partner)
    end

    def create
      intake = Intake.find_by(id: params[:intake_id])
      return head 422 unless intake.present?

      # Don't create additional clients if we already have one
      return redirect_to case_management_client_path(id: intake.client_id) if intake.client_id.present?

      client = Client.create_from_intake(intake)
      intake.update(client: client)
      redirect_to case_management_client_path(id: client.id)
    end

    def show
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
end