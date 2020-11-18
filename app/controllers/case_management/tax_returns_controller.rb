module CaseManagement
  class TaxReturnsController < ApplicationController
    include AccessControllable

    before_action :require_sign_in
    load_and_authorize_resource :client
    load_and_authorize_resource through: :client
    before_action :set_assignable_users, only: [:edit]

    layout "admin"

    def edit; end

    def update
      @tax_return.update!(assign_params)
      no_one = I18n.t("case_management.tax_returns.update.no_one")
      success_message = I18n.t(
        "case_management.tax_returns.update.flash_success",
        assignee_name: @tax_return.assigned_user.present? ? @tax_return.assigned_user.name : no_one,
        client_name: @client.preferred_name,
        tax_year: @tax_return.year,
      )
      redirect_to case_management_clients_path, notice: success_message
    end

    def edit_status
      # prefill status if we received a param
      preselected_status = params[:tax_return][:status] if params[:tax_return] && params[:tax_return][:status]

      @take_action_form = CaseManagement::TakeActionForm.new(
        @client,
        status: preselected_status || @tax_return.status,
        locale: @client.intake.locale,
        message_body: status_macro(preselected_status),
        contact_method: preferred_contact_method_or_default
      )
    end

    def update_status
      if @tax_return.update(status_params)
        SystemNote.create_status_change_note(current_user, @tax_return)
        redirect_to case_management_client_messages_path(client_id: @client.id)
      end
    end

    private

    def preferred_contact_method_or_default
      default = "email"
      prefers_sms_only = @client.intake.sms_notification_opt_in_yes? && @client.intake.email_notification_opt_in_no?
      prefers_sms_only ? "text_message" : default
    end

    def status_macro(status)
      if ["intake_more_info", "prep_more_info", "review_more_info"].include?(status)
        I18n.t('case_management.tax_returns.edit_status.status_macros.needs_more_information', required_documents: "<<LIST_OF_REQUIRED_DOCS>>", document_upload_link: "<<DOC_LINK>>", locale: @client.intake.locale)
      elsif status == "prep_ready_for_review"
        I18n.t('case_management.tax_returns.edit_status.status_macros.ready_for_qr', locale: @client.intake.locale)
      elsif status == "filed_accepted"
        I18n.t('case_management.tax_returns.edit_status.status_macros.accepted', locale: @client.intake.locale)
      else
        ""
      end
    end

    def set_assignable_users
      @assignable_users = @client.vita_partner.users
    end

    def assign_params
      params.require(:tax_return).permit(:assigned_user_id)
    end

    def status_params
      params.require(:tax_return).permit(:status)
    end
  end
end