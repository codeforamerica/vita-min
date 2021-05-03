module Documents
  class DocumentsHelpController < DocumentUploadQuestionController
    layout "intake"
    skip_before_action :set_current_step
    before_action :redirect_unless_next_path

    def show
      @doc_type = params[:doc_type]
    end

    def send_reminder
      ClientMessagingService.send_system_message_to_all_opted_in_contact_methods(
        current_intake.client,
        email_body: I18n.t("documents.reminder_link.email_body_html",
                           first_name: current_intake.preferred_name,
                           doc_type: params[:doc_type].constantize.key,
                           reminder_link: new_portal_client_login_url
        ),
        sms_body: I18n.t("documents.reminder_link.sms_body",
                         first_name: current_intake.preferred_name,
                         doc_type: params[:doc_type].constantize.key,
                         reminder_link: new_portal_client_login_url
        ),
        subject: I18n.t("documents.reminder_link.subject")
      )
      flash[:notice] = I18n.t("documents.reminder_link.notice")
      redirect_to(next_path)
    end

    def request_doc_help
      raise ArgumentError unless DocumentTypes::HELP_TYPES.include? params[:help_type].to_sym
      current_client.request_document_help(doc_type: params[:doc_type].constantize, help_type: params[:help_type])
      flash[:notice] = I18n.t("documents.updated_specialist.notice")
      redirect_to(next_path)
    end

    #doc help --> create doc_type: SystemNote::DocumentHelp; help_type: :doesnt_apply

    private

    def redirect_unless_next_path
      redirect_back(fallback_location: portal_root_path) unless params[:next_path].present?
    end

    def illustration_path; end

    def next_path
      params[:next_path]
    end

    def prev_path
      :back
    end
  end
end

