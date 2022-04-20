module Hub
  class ClientsController < ApplicationController
    FILTER_COOKIE_NAME = "all_clients_filters".freeze
    include AccessControllable
    include ClientSortable

    before_action :require_sign_in
    before_action :load_vita_partners, only: [:new, :create, :index]
    before_action :load_users, :setup_sortable_client, only: [:index]
    load_and_authorize_resource except: [:new, :create, :resource_to_client_redirect]
    layout "hub"

    MAX_COUNT = 1000

    def index
      @page_title = I18n.t("hub.clients.index.title")

      # Compute the count of tax returns, up to a maximum amount. Postgres is slow at computing counts if they are very large.
      tax_return_count = TaxReturn.where(client: filtered_clients.with_eager_loaded_associations.without_pagination.reorder(nil)).limit(MAX_COUNT + 1).size
      # @tax_return_count HAS to be defined before @clients, otherwise it will cause SQL errors
      @tax_return_count = tax_return_count > MAX_COUNT ? "" : tax_return_count.to_s
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

    def show
      @client = HubClientPresenter.new(@client)
    end

    def edit
      return render "public_pages/page_not_found", status: 404 if @client.intake.is_ctc?

      @form = UpdateClientForm.from_client(@client)
    end

    def update
      original_intake = @client.intake.dup
      # need to use the presenter bc it has ITIN applicant methods that are used in the form
      @client = HubClientPresenter.new(@client)
      @form = UpdateClientForm.new(@client, update_client_form_params)

      if @form.valid? && @form.save
        SystemNote::ClientChange.generate!(initiated_by: current_user, original_intake: original_intake, intake: @client.intake)
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

    def toggle_field
      original_intake = @client.intake.dup
      @client.intake.update(toggle_field_params)
      SystemNote::ClientChange.generate!(initiated_by: current_user, original_intake: original_intake, intake: @client.intake)
    end

    def edit_take_action
      @take_action_form = Hub::TakeActionForm.new(
        @client,
        current_user,
        tax_return_id: params.dig(:tax_return, :id)&.to_i,
        status: params.dig(:tax_return, :current_state) || params.dig(:tax_return, :status),
        locale: params.dig(:tax_return, :locale)
      )
    end

    def update_take_action
      @client = HubClientPresenter.new(@client)

      unless @client.hub_status_updatable
        return head :bad_request
      end

      @take_action_form = Hub::TakeActionForm.new(@client, current_user, take_action_form_params)
      if @take_action_form.valid?
        action_list = TaxReturnService.handle_state_change(@take_action_form)
        flash[:notice] = I18n.t("hub.clients.update_take_action.flash_message.success", action_list: action_list.join(", ").capitalize)
        redirect_to hub_client_path(id: @client)
      else
        flash[:alert] = I18n.t("forms.errors.general")
        render :edit_take_action
      end
    end

    def unlock
      raise CanCan::AccessDenied unless current_user.admin? || current_user.org_lead? || current_user.site_coordinator?

      @client.unlock_access! if @client.access_locked?
      flash[:notice] = I18n.t("hub.clients.unlock.account_unlocked", name: @client.preferred_name)
      redirect_to(hub_client_path(id: @client))
    end

    # Provided an ID of a resource with a relationship to a client, find the client and redirect to their client page
    # Used to link to client pages when identifying duplicated data
    def resource_to_client_redirect
      resource_id = params[:id]
      resource_name = params[:resource]
      resource = resource_name.camelize.constantize.find(resource_id)
      client = resource.is_a?(Client) ? resource : resource.client
      redirect_to hub_client_path(id: client)
    end

    private

    def flag_params
      params.require(:client).permit(:action)
    end

    def toggle_field_params
      params.require(:client).permit(:used_itin_certifying_acceptance_agent)
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

    class HubClientPresenter < SimpleDelegator
      attr_reader :intake
      attr_reader :archived
      alias_method :archived?, :archived
      attr_reader :missing_intake
      alias_method :missing_intake?, :missing_intake

      def self.delegated_intake_attributes
        [
          :preferred_name,
          :email_address,
          :phone_number,
          :sms_phone_number,
          :locale,
          :used_itin_certifying_acceptance_agent,
          :used_itin_certifying_acceptance_agent?,
        ]
      end

      delegate *delegated_intake_attributes, to: :intake

      def initialize(client)
        @client = client
        __setobj__(client)
        @intake = client.intake
        unless @intake
          @intake = Archived::Intake2021.find_by(client_id: @client.id)
          @archived = true if @intake
        end
        # For a short while, we created Client records with no intake and/or moved which client the intake belonged to.
        if !@intake && @client.created_at < Date.parse('2022-04-15')
          @missing_intake = true
          @intake = Intake::GyrIntake.new(client_id: @client.id)
          @intake.readonly!
        end
      end

      def editable?
        !!@client.intake
      end

      def hub_status_updatable
        @client.intake && !@client.online_ctc?
      end

      def requires_spouse_info?
        return false unless intake

        intake.filing_joint == "yes" || !tax_returns.map(&:filing_status).all?("single")
      end

      def needs_itin_help_text
        return I18n.t("general.NA") if archived?

        intake.itin_applicant? ? I18n.t("general.affirmative") : I18n.t("general.negative")
      end

      def needs_itin_help_yes?
        return false if archived?

        intake.itin_applicant?
      end
    end
  end
end
