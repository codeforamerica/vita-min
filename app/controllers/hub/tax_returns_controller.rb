module Hub
  class TaxReturnsController < ApplicationController
    include AccessControllable
    include MessageSending

    before_action :require_sign_in
    load_and_authorize_resource :client
    load_and_authorize_resource through: :client
    before_action :set_assignable_users, only: [:edit]

    layout "admin"

    def edit; end

    def update
      @tax_return.update!(assign_params)
      no_one = I18n.t("hub.tax_returns.update.no_one")
      success_message = I18n.t(
        "hub.tax_returns.update.flash_success",
        assignee_name: @tax_return.assigned_user.present? ? @tax_return.assigned_user.name : no_one,
        client_name: @client.preferred_name,
        tax_year: @tax_return.year,
      )
      redirect_to hub_clients_path, notice: success_message
    end

    def edit_status
      # prefill status if we received a param
      preselected_status = params.dig(:tax_return, :status)

      @take_action_form = Hub::TakeActionForm.new(
        @client,
        status: preselected_status || @tax_return.status,
        locale: @client.intake.locale,
        message_body: status_macro(preselected_status),
        contact_method: preferred_contact_method_or_default
      )
    end

    def update_status
      @take_action_form = Hub::TakeActionForm.new(@client, take_action_form_params)
      if @take_action_form.valid?
        action_list = []
        if @take_action_form.status != @tax_return.status
          @tax_return.update!(status: @take_action_form.status)
          SystemNote.create_status_change_note(current_user, @tax_return)
          action_list << I18n.t("hub.tax_returns.edit_status.flash_message.status")
        end

        if @take_action_form.message_body.present?
          case @take_action_form.contact_method
          when "email"
            send_email(@take_action_form.message_body, subject_locale: @take_action_form.locale)
            action_list << I18n.t("hub.tax_returns.edit_status.flash_message.email")
          when "text_message"
            send_text_message(@take_action_form.message_body)
            action_list << I18n.t("hub.tax_returns.edit_status.flash_message.text_message")
          end
        end

        if @take_action_form.internal_note_body.present?
          Note.create!(
            body: @take_action_form.internal_note_body,
            client: @client,
            user: current_user
          )
          action_list << I18n.t("hub.tax_returns.edit_status.flash_message.internal_note")
        end

        flash[:notice] = I18n.t("hub.tax_returns.edit_status.flash_message.success", action_list: action_list.join(", ").capitalize)

        redirect_to hub_client_path(id: @client)
      end
    end

    private

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
          "hub.tax_returns.edit_status.status_macros.needs_more_information",
          required_documents: document_list,
          document_upload_link: @client.intake.requested_docs_token_link,
          locale: @client.intake.locale
        )
      when "prep_ready_for_review"
        I18n.t("hub.tax_returns.edit_status.status_macros.ready_for_qr", locale: @client.intake.locale)
      when "filed_accepted"
        I18n.t("hub.tax_returns.edit_status.status_macros.accepted", locale: @client.intake.locale)
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

    def take_action_form_params
      params.require(:hub_take_action_form).permit(:status, :locale, :message_body, :contact_method, :internal_note_body)
    end
  end
end
