module CaseManagement
  class ClientsController < ApplicationController
    include AccessControllable
    include ClientSortable

    before_action :require_sign_in
    before_action :setup_sortable_client, only: [:index]
    load_and_authorize_resource except: :create
    layout "admin"

    def index
      @page_title = I18n.t("case_management.clients.index.title")
      @clients = @clients.delegated_order(@sort_column, @sort_order)
    end

    def create
      # Manual access control for create method, since there is no client yet
      return head 403 unless current_user.present?

      intake = Intake.find_by(id: params[:intake_id])
      return head 422 unless intake.present?

      # Don't create additional clients if we already have one
      return redirect_to case_management_client_path(id: intake.client_id) if intake.client_id.present?

      client = Client.create!(intake: intake, vita_partner: intake.vita_partner)
      redirect_to case_management_client_path(id: client.id)
    end

    def show; end

    def edit
      @form = ClientIntakeForm.from_intake(@client.intake)
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
