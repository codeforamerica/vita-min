module Documents
  class DocumentsHelpController < DocumentUploadQuestionController
    layout "intake"
    skip_before_action :set_current_step
    before_action :redirect_unless_next_path

    def show; end

    def send_reminder
      doc_type = document_type_from_param.key
      ClientMessagingService.send_system_message_to_all_opted_in_contact_methods(
        client: current_intake.client,
        email_body: I18n.t("documents.reminder_link.email_body", doc_type: doc_type),
        sms_body: I18n.t("documents.reminder_link.sms_body", doc_type: doc_type),
        subject: I18n.t("documents.reminder_link.subject"),
        locale: I18n.locale
      )
      flash[:notice] = I18n.t("documents.reminder_link.notice")
      redirect_to(next_path)
    end

    def request_doc_help
      raise ArgumentError unless DocumentTypes::HELP_TYPES.include? params[:help_type].to_sym

      current_client.request_document_help(doc_type: document_type_from_param, help_type: params[:help_type])
      flash[:notice] = I18n.t("documents.updated_specialist.notice")
      redirect_to(next_path)
    end

    def document_type_from_param
      document_type = DocumentType.from_param(params[:doc_type])
      # support existing class name doc types
      begin
        document_type = params[:doc_type].constantize&.key unless document_type.present?
      rescue
        raise ArgumentError, "Invalid document type" unless document_type.present?
      end

      raise ArgumentError, "Invalid document type" unless document_type.present?

      document_type
    end

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

