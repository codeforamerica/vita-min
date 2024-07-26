module Hub
  class ClientsController < Hub::BaseController
    FILTER_COOKIE_NAME = "all_clients_filters".freeze
    include ClientSortable

    before_action :load_vita_partners, only: [:new, :create, :index]
    before_action :load_users, only: [:index]
    load_and_authorize_resource except: [:new, :create, :resource_to_client_redirect]
    before_action :setup_sortable_client, only: [:index]
    # need to use the presenter for :update bc it has ITIN applicant methods that are used in the form
    before_action :wrap_client_in_hub_presenter, only: [:show, :edit, :edit_take_action, :update, :update_take_action]
    before_action :redirect_unless_client_is_hub_status_editable, only: [:edit, :edit_take_action, :update, :update_take_action]
    layout "hub"

    MAX_COUNT = 1000

    def index
      @page_title = I18n.t("hub.clients.index.title")

      @clients = @client_sorter.filtered_and_sorted_clients.page(params[:page]).load
      @message_summaries = RecentMessageSummaryService.messages(@clients.map(&:id))
    end

    def new
      @current_year = MultiTenantService.new(:gyr).current_tax_year
      @form = CreateClientForm.new
    end

    def create
      @current_year = MultiTenantService.new(:gyr).current_tax_year
      @form = CreateClientForm.new(create_client_form_params)
      assigned_vita_partner = @vita_partners.find_by(id: create_client_form_params["vita_partner_id"])

      if can?(:read, assigned_vita_partner) && @form.save(current_user)
        flash[:notice] = I18n.t("hub.clients.create.success_message")
        redirect_to hub_client_path(id: @form.client)
      else
        flash[:alert] = I18n.t("forms.errors.general")
        render :new
      end
    end

    def destroy
      @client.destroy!
      flash[:notice] = I18n.t("hub.clients.destroy.success_message")
      redirect_to hub_clients_path
    end

    def edit
      return render "public_pages/page_not_found", status: 404 if @client.intake.is_ctc?

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

    def toggle_field
      @client.intake.update(toggle_field_params)
      SystemNote::ClientChange.generate!(initiated_by: current_user, intake: @client.intake)
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

    def edit_13614c_form_page1
      @form = Update13614cFormPage1.from_client(@client)
    end

    def edit_13614c_form_page2
      @form = Update13614cFormPage2.from_client(@client)
    end

    def edit_13614c_form_page3
      @form = Update13614cFormPage3.from_client(@client)
    end

    def save_and_maybe_exit(save_button_clicked, path_to_13614c_page)
      if save_button_clicked == I18n.t("general.save")
        redirect_to path_to_13614c_page
      else # should always be: params[:commit] == I18n.t("general.save_and_exit")
        redirect_to hub_client_path(id: @client.id)
      end
    end

    def update_13614c_form_page1
      @form = Update13614cFormPage1.new(@client, update_13614c_form_page1_params)

      if @form.valid? && @form.save
        SystemNote::ClientChange.generate!(initiated_by: current_user, intake: @client.intake)
        GenerateF13614cPdfJob.perform_later(@client.intake.id, "Hub Edited 13614-C.pdf")
        flash[:notice] = I18n.t("general.changes_saved")
        save_and_maybe_exit(params[:commit], edit_13614c_form_page1_hub_client_path(id: @client.id))
      else
        flash[:alert] = I18n.t("forms.errors.general")
        render :edit_13614c_form_page1
      end
    end

    def update_13614c_form_page2
      @form = Update13614cFormPage2.new(@client, update_13614c_form_page2_params)

      if @form.valid? && @form.save
        SystemNote::ClientChange.generate!(initiated_by: current_user, intake: @client.intake)
        GenerateF13614cPdfJob.perform_later(@client.intake.id, "Hub Edited 13614-C.pdf")
        flash[:notice] = I18n.t("general.changes_saved")
        save_and_maybe_exit(params[:commit], edit_13614c_form_page2_hub_client_path(id: @client.id))
      end
    end

    def update_13614c_form_page3
      @form = Update13614cFormPage3.new(@client, update_13614c_form_page3_params)

      if @form.valid? && @form.save
        SystemNote::ClientChange.generate!(initiated_by: current_user, intake: @client.intake)
        @client.intake.update(demographic_questions_hub_edit: true)
        GenerateF13614cPdfJob.perform_later(@client.intake.id, "Hub Edited 13614-C.pdf")
        flash[:notice] = I18n.t("general.changes_saved")
        save_and_maybe_exit(params[:commit], edit_13614c_form_page3_hub_client_path(id: @client.id))
      end
    end

    def cancel_13614c
      redirect_to hub_client_path(id: @client.id)
    end

    # Provided an ID of a resource with a relationship to a client, find the client and redirect to their client page
    # Used to link to client pages when identifying duplicated data
    def resource_to_client_redirect
      resource_id = params[:id]
      resource_name = params[:resource]
      redirect_to hub_clients_path and return unless resource_name
      resource = Fraud::Indicator.reference_to_resource(resource_name)&.find(resource_id)

      # When the resource is not valid, resource is nil. We ought to do a regular 404 in that case
      raise ActiveRecord::RecordNotFound unless resource

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

    def update_13614c_form_page1_params
      params.require(Update13614cFormPage1.form_param).permit(Update13614cFormPage1.permitted_params)
    end

    def update_13614c_form_page2_params
      params.require(Update13614cFormPage2.form_param).permit(Update13614cFormPage2.attribute_names)
    end

    def update_13614c_form_page3_params
      params.require(Update13614cFormPage3.form_param).permit(Update13614cFormPage3.attribute_names)
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

    def wrap_client_in_hub_presenter
      @client = HubClientPresenter.new(@client)
    end

    def redirect_unless_client_is_hub_status_editable
      redirect_to hub_client_path(id: @client.id) unless @client.hub_status_updatable
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
        if @intake.present? && @intake.product_year != Rails.configuration.product_year
          @archived = true
        end
        if @intake.blank?
          @intake = Archived::Intake2021.find_by(client_id: @client.id)
          @archived = true if @intake
        end
        # For a short while, we created Client records with no intake and/or moved which client the intake belonged to.
        if !@intake && @client.created_at < Date.parse('2022-04-15')
          @missing_intake = true
          @intake = Intake::GyrIntake.new(client_id: @client.id)
          @intake.readonly!
        end
        @intake = HubIntakePresenter.new(@intake)
      end

      def urbanization
        @intake.urbanization if @intake.respond_to?(:urbanization)
      end

      def editable?
        @client.intake.present? && @client.intake.product_year == Rails.configuration.product_year
      end

      def required_documents_tooltip
        return nil if @intake.is_ctc?

        lines = ["Total: #{@client.filterable_number_of_required_documents_uploaded} / #{@client.filterable_number_of_required_documents}"]
        lines << [""]
        @client.required_document_counts.select { |document_type, counts| counts[:required_count] > 0 }.map do |document_type, counts|
          lines << "#{document_type}: #{counts[:clamped_provided_count]} / #{counts[:required_count]}"
        end
        lines.join("\n")
      end

      def hub_status_updatable
        editable? && !@client.online_ctc?
      end

      def requires_spouse_info?
        return false unless intake

        intake.filing_joint == "yes" || !tax_returns.map(&:filing_status).all?("single")
      end

      def needs_itin_help_text
        return I18n.t("general.NA") if archived?

        intake.itin_applicant? ? I18n.t("general.affirmative") : I18n.t("general.negative")
      end

      def preferred_language
        return intake.preferred_interview_language if intake.preferred_interview_language && intake.preferred_interview_language != "en"

        intake.locale || intake.preferred_interview_language
      end

      def needs_itin_help_yes?
        return false if archived?

        intake.itin_applicant?
      end
    end

    class HubIntakePresenter < SimpleDelegator
      def initialize(intake)
        @intake = intake
        __setobj__(intake)
      end

      def primary
        return @intake.primary if @intake.is_a?(Intake)

        Intake::Person.new(@intake, :primary)
      end

      def spouse
        return @intake.spouse if @intake.is_a?(Intake)

        Intake::Person.new(@intake, :spouse)
      end

      def product_year
        if @intake.is_a?(Archived::Intake2021)
          return 2021
        end
        @intake.product_year
      end
    end
  end
end
