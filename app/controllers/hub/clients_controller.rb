module Hub
  class ClientsController < ApplicationController
    include AccessControllable
    include ClientSortable
    include MessageSending

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
        render :new
      end
    end

    def show; end

    def edit
      @form = ClientIntakeForm.from_intake(@client.intake)
    end

    def update
      @form = ClientIntakeForm.new(@client.intake, client_intake_form_params)

      if @form.valid? && @form.save
        redirect_to hub_client_path(id: @client.id)
      else
        flash[:warning] = @form.errors[:dependents_attributes].join("") if @form.errors[:dependents_attributes].present?
        render :edit
      end
    end

    def response_needed
      @client.clear_response_needed if params.fetch(:client, {})[:action] == "clear"
      @client.touch(:response_needed_since) if params.fetch(:client, {})[:action] == "set"
      redirect_back(fallback_location: hub_client_path(id: @client.id))
    end

    def edit_take_action
      @tax_returns = @client.tax_returns.order(year: :asc).to_a

      # The `tax_return` param of the form takes an array of ActiveRecord-esque objects
      tax_return_struct = Struct.new(:id, :status, :year, :errors)
      no_errors_hash = Hash.new(Struct.new(:any?).new(false))

      # populate tax return statuses with params or existing value
      tax_return_params = []
      preselected_status = params.dig(:tax_return, :status)
      @tax_returns.each do |tax_return|
        status =
          if params.dig(:tax_return, :id) == tax_return.id.to_s
            preselected_status
          else
            tax_return.status
          end
        tax_return_params.push(tax_return_struct.new(tax_return.id, status, tax_return.year, no_errors_hash))
      end

      @take_action_form = Hub::TakeActionForm.new(
        @client,
        locale: @client.intake.locale,
        message_body: status_macro(preselected_status),
        contact_method: preferred_contact_method_or_default,
        tax_returns: tax_return_params,
      )
    end

    def update_take_action
      @take_action_form = Hub::TakeActionForm.new(@client, take_action_form_params)

      if @take_action_form.valid?
        action_list = []

        # update tax return statuses
        if @take_action_form.tax_returns.present?
          status_changed = false
          @take_action_form.tax_returns.keys.each do |tax_return_id|
            tax_return = @client.tax_returns.find(tax_return_id)
            new_status = @take_action_form.tax_returns[tax_return_id]["status"]
            if new_status != tax_return.status
              tax_return.update!(status: new_status)
              SystemNote.create_status_change_note(current_user, tax_return)
              status_changed = true
            end
          end
          action_list << I18n.t("hub.clients.update_take_action.flash_message.status") if status_changed
        end

        # send message(s)
        if @take_action_form.message_body.present?
          case @take_action_form.contact_method
          when "email"
            send_email(@take_action_form.message_body, subject_locale: @take_action_form.locale)
            action_list << I18n.t("hub.clients.update_take_action.flash_message.email")
          when "text_message"
            send_text_message(@take_action_form.message_body)
            action_list << I18n.t("hub.clients.update_take_action.flash_message.text_message")
          end
        end

        # create internal note
        if @take_action_form.internal_note_body.present?
          Note.create!(
            body: @take_action_form.internal_note_body,
            client: @client,
            user: current_user
          )
          action_list << I18n.t("hub.clients.update_take_action.flash_message.internal_note")
        end

        flash[:notice] = I18n.t("hub.clients.update_take_action.flash_message.success", action_list: action_list.join(", ").capitalize)

        redirect_to hub_client_path(id: @client)
      end
    end

    private

    def load_vita_partners
      @vita_partners = VitaPartner.accessible_by(Ability.new(current_user))
    end

    def client_intake_form_params
      params.require(ClientIntakeForm.form_param).permit(ClientIntakeForm.permitted_params)
    end

    def create_client_form_params
      params.require(CreateClientForm.form_param).permit(CreateClientForm.permitted_params)
    end

    def take_action_form_params
      params.require(TakeActionForm.form_param).permit(TakeActionForm.permitted_params)
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
          "hub.status_macros.needs_more_information",
          required_documents: document_list,
          document_upload_link: @client.intake.requested_docs_token_link,
          locale: @client.intake.locale
        )
      when "prep_ready_for_review"
        I18n.t("hub.status_macros.ready_for_qr", locale: @client.intake.locale)
      when "filed_accepted"
        I18n.t("hub.status_macros.accepted", locale: @client.intake.locale)
      else
        ""
      end
    end
  end
end
