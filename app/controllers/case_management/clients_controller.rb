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

      client = Client.create!
      intake.update(client: client)
      redirect_to case_management_client_path(id: client.id)
    end

    def show; end

    def edit
      @form = ClientIntakeForm.new(@client.intake)
    end

    def update
      @form = ClientIntakeForm.new(@client.intake, form_params)
      if @form.valid?
        @form.save
        redirect_to case_management_client_path(id: @client.id)
      else
        render :edit
      end
    end

    def response_needed
      @client.clear_response_needed if params.fetch(:client, {})[:action] == "clear"
      @client.touch(:response_needed_since) if params.fetch(:client, {})[:action] == "set"
      redirect_back(fallback_location: case_management_client_path(id: @client.id))
    end

    private

    def form_params
      params.require(:case_management_client_intake_form).permit(ClientIntakeForm.attribute_names)
    end
  end
end