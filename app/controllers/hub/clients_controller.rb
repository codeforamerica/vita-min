module Hub
  class ClientsController < ApplicationController
    FILTER_COOKIE_NAME = "all_clients_filters".freeze
    include AccessControllable
    include ClientSortable

    before_action :require_sign_in
    before_action :load_vita_partners, only: [:new, :create, :index]
    before_action :load_users, only: [:index]
    load_and_authorize_resource except: [:new, :create]
    layout "admin"

    def index
      @page_title = I18n.t("hub.clients.index.title")
      @clients = filtered_and_sorted_clients.with_eager_loaded_associations.page(params[:page]).load
      @message_summaries = RecentMessageSummaryService.messages(@clients.map(&:id))
    end

    def new
      @form = CreateClientForm.new
    end

    def create
      @form = CreateClientForm.new(create_client_form_params)
      assigned_vita_partner = VitaPartner.find_by(id: create_client_form_params["vita_partner_id"])

      if can?(:read, assigned_vita_partner) && @form.save(current_user)
        flash[:notice] = I18n.t("hub.clients.create.success_message")
        redirect_to hub_client_path(id: @form.client)
      else
        flash[:alert] = I18n.t("forms.errors.general")
        render :new
      end
    end

    def destroy
      Client.find(params[:id]).destroy!
      flash[:notice] = I18n.t("hub.clients.destroy.success_message")
      redirect_to hub_clients_path
    end

    def show; end

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
        SystemNote::ClientChange.generate!(initiated_by: current_user, intake: @client.intake)
        redirect_to hub_client_path(id: @client.id)
      else
        flash[:alert] = I18n.t("forms.errors.general")
        render :edit
      end
    end

    def flag
      case flag_params[:action]
      when "clear"
        @client.clear_flag!
        SystemNote::ResponseNeededToggledOff.generate!(client: @client, initiated_by: current_user)
      when "set"
        @client.flag!
        SystemNote::ResponseNeededToggledOn.generate!(client: @client, initiated_by: current_user)
      end

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
      if @take_action_form.valid?
        action_list = TaxReturnService.handle_status_change(@take_action_form)
        flash[:notice] = I18n.t("hub.clients.update_take_action.flash_message.success", action_list: action_list.join(", ").capitalize)
        redirect_to hub_client_path(id: @client)
      else
        flash[:alert] = I18n.t("forms.errors.general")
        render :edit_take_action
      end
    end

    def unlock
      raise CanCan::AccessDenied unless current_user.admin?

      @client.unlock_access! if @client.access_locked?
      flash[:notice] = I18n.t("hub.clients.unlock.account_unlocked", name: @client.preferred_name)
      redirect_to(hub_client_path(id: @client))
    end

    private

    def flag_params
      params.require(:client).permit(:action)
    end

    def update_client_form_params
      params.require(UpdateClientForm.form_param).permit(UpdateClientForm.permitted_params)
    end

    def create_client_form_params
      params.require(CreateClientForm.form_param).permit(CreateClientForm.permitted_params)
    end

    def take_action_form_params
      params.require(TakeActionForm.form_param).permit(TakeActionForm.permitted_params)
    end

    def filter_cookie_name
      FILTER_COOKIE_NAME
    end
  end
end
