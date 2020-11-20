module Hub
  class ClientsController < ApplicationController
    include AccessControllable
    include ClientSortable
    include TaxReturnStatusHelper

    before_action :require_sign_in
    before_action :setup_sortable_client, only: [:index]
    load_and_authorize_resource except: :create
    layout "admin"

    def index
      @page_title = I18n.t("hub.clients.index.title")
      @clients = filtered_and_sorted_clients
    end

    def create
      # Manual access control for create method, since there is no client yet
      return head 403 unless current_user.present?

      intake = Intake.find_by(id: params[:intake_id])
      return head 422 unless intake.present?

      # Don't create additional clients if we already have one
      return redirect_to hub_client_path(id: intake.client_id) if intake.client_id.present?

      client = Client.create!(intake: intake, vita_partner: intake.vita_partner)
      redirect_to hub_client_path(id: client.id)
    end

    def show; end

    def edit
      @form = ClientIntakeForm.from_intake(@client.intake)
    end

    def update
      @form = ClientIntakeForm.new(@client.intake, form_params)
      if @form.valid?
        @form.save
        redirect_to hub_client_path(id: @client.id)
      else
        render :edit
      end
    end

    def response_needed
      @client.clear_response_needed if params.fetch(:client, {})[:action] == "clear"
      @client.touch(:response_needed_since) if params.fetch(:client, {})[:action] == "set"
      redirect_back(fallback_location: hub_client_path(id: @client.id))
    end

    def edit_take_action
      @tax_returns = @client.tax_returns.to_a

      @take_action_form = CaseManagement::TakeActionForm.new(
          @client,
          status: "",
          locale: @client.intake.locale,
          message_body: "",
          contact_method: "",
          tax_returns: @tax_returns
      )
    end

    def update_take_action
      binding.pry
    end

    private

    def form_params
      params.require(:hub_client_intake_form).permit(ClientIntakeForm.attribute_names)
    end
  end
end
