module CaseManagement
  class ClientsController < ApplicationController
    include AccessControllable

    before_action :require_sign_in
    load_and_authorize_resource

    layout "admin"

    def index
      @clients = @clients.includes(intake: :vita_partner)
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

    def show; end
  end
end