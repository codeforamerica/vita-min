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

      # populate tax return statuses with params or existing value
      tax_return_params = {}
      preselected_status = params.dig(:tax_return, :status)
      @tax_returns.each do|tax_return|
        if params.dig(:tax_return, :id) == tax_return.id.to_s
          tax_return_params[tax_return.id] = preselected_status
        else
          tax_return_params[tax_return.id] = tax_return.status
        end
      end

      @take_action_form = CaseManagement::TakeActionForm.new(
        @client,
        locale: @client.intake.locale,
        message_body: status_macro(preselected_status),
        contact_method: preferred_contact_method_or_default,
        tax_return: tax_return_params,
      )
    end

    # def update_take_action
    # end

    private

    def form_params
      params.require(:hub_client_intake_form).permit(ClientIntakeForm.attribute_names)
    end

    def preferred_contact_method_or_default
      default = "email"
      prefers_sms_only = @client.intake.sms_notification_opt_in_yes? && @client.intake.email_notification_opt_in_no?
      prefers_sms_only ? "text_message" : default
    end

    def status_macro(status)
      case status
      when "intake_more_info", "prep_more_info", "review_more_info"
        document_list = @client.intake.relevant_document_types.map do |doc_type|
          "  - " + doc_type.translated_label(@client.intake.locale)
        end.join("\n")
        I18n.t(
          "case_management.tax_returns.edit_status.status_macros.needs_more_information",
          required_documents: document_list,
          document_upload_link: @client.intake.requested_docs_token_link,
          locale: @client.intake.locale
        )
      when "prep_ready_for_review"
        I18n.t("case_management.tax_returns.edit_status.status_macros.ready_for_qr", locale: @client.intake.locale)
      when "filed_accepted"
        I18n.t("case_management.tax_returns.edit_status.status_macros.accepted", locale: @client.intake.locale)
      else
        ""
      end
    end
  end
end
