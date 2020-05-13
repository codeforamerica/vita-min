module Documents
  class SendRequestedDocumentsLaterController < DocumentUploadQuestionController
    after_action :clear_anonymous_session
    skip_before_action :require_ticket

    def edit
      original_intake = find_original_intake
      original_intake.documents << current_intake.documents
      SendRequestedDocumentsToZendeskJob.perform_later(original_intake.id)
      redirect_to documents_requested_documents_success_path
    end

    def success
      render layout: "application"
    end

    def self.show?(_)
      false
    end

    def self.document_type
      nil
    end

    private

    def clear_anonymous_session
      if session[:anonymous_session]
        intake = Intake.anonymous.find_by(id: session[:intake_id])
        intake.destroy if intake
        session[:anonymous_session] = false
        session[:intake_id] = nil
      end
    end

    def find_original_intake
      if session[:anonymous_session]
        Intake.find_original_intake(current_intake)
      else
        current_intake
      end
    end
  end
end

