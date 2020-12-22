module Hub
  class ClientsController < ApplicationController
    include AccessControllable
    include ClientSortable

    before_action :require_sign_in
    before_action :load_vita_partners, only: [:new, :create]
    load_and_authorize_resource except: [:new, :create]
    layout "admin"

    def index
      @page_title = I18n.t("hub.clients.index.title")
      @clients = filtered_and_sorted_clients
    end

    def new
      @form = CreateClientForm.new
    end

    def create
      @form = CreateClientForm.new(create_client_form_params)
      if @form.save
        flash[:notice] = I18n.t("hub.clients.create.success_message")
        redirect_to hub_client_path(id: @form.client)
      else
        flash[:alert] = I18n.t("forms.errors.general")
        render :new
      end
    end

    def show;end

    def request_bank_account_info
      @client = Client.find(params[:id])
      respond_to :js
    end

    def edit
      @form = UpdateClientForm.from_client(@client)
    end

    def update
      @form = UpdateClientForm.new(@client, update_client_form_params)

      if @form.valid? && @form.save
        SystemNote.create_client_change_note(current_user, @client.intake)
        redirect_to hub_client_path(id: @client.id)
      else
        flash[:alert] = I18n.t("forms.errors.general")
        render :edit
      end
    end

    def attention_needed
      @client.clear_attention_needed if params.fetch(:client, {})[:action] == "clear"
      @client.touch(:attention_needed_since) if params.fetch(:client, {})[:action] == "set"
      redirect_back(fallback_location: hub_client_path(id: @client.id))
    end

    def edit_take_action
      @take_action_form = Hub::TakeActionForm.new(
        @client,
        current_user,
        tax_return_id: params.dig(:tax_return, :id)&.to_i,
        status: params.dig(:tax_return, :status),
        locale: params.dig(:tax_return, :locale)
      )
    end

    def update_take_action
      @take_action_form = Hub::TakeActionForm.new(@client, current_user, take_action_form_params)
      if @take_action_form.take_action
        flash[:notice] = I18n.t("hub.clients.update_take_action.flash_message.success", action_list: @take_action_form.action_list.join(", ").capitalize)
        redirect_to hub_client_path(id: @client)
      else
        flash[:alert] = I18n.t("forms.errors.general")
        render :edit_take_action
      end
    end

    private

    def load_vita_partners
      @vita_partners = VitaPartner.accessible_by(current_ability)
    end

    def update_client_form_params
      params.require(UpdateClientForm.form_param).permit(UpdateClientForm.permitted_params)
    end

    def create_client_form_params
      default_vita_partner_id = current_user.role_type == "OrganizationLeadRole" ? current_user.role.organization.id : nil
      filtered_params = params.require(CreateClientForm.form_param).permit(CreateClientForm.permitted_params)
      filtered_params = filtered_params.merge(vita_partner_id: default_vita_partner_id) unless can?(:manage, VitaPartner)
      filtered_params
    end

    def take_action_form_params
      params.require(TakeActionForm.form_param).permit(TakeActionForm.permitted_params)
    end
  end
end
