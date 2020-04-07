module Documents
  class RequestedDocumentsLaterController < DocumentUploadQuestionController
    before_action :check_token_and_create_anonymous_session, only: :edit
    skip_before_action :require_sign_in

    def self.show?(_)
      false
    end

    def next_path(params = {})
      send_requested_documents_later_documents_path
    end

    def not_found
      render layout: "application"
    end

    private

    def check_token_and_create_anonymous_session
      original_intake = Intake.where.not(requested_docs_token: nil).where(requested_docs_token: params[:token]).first
      return redirect_to documents_requested_docs_not_found_path unless original_intake.present?

      create_anonymous_intake_session(original_intake) unless session[:anonymous_session]
    end

    def create_anonymous_intake_session(original_intake)
      anonymous_intake = Intake.create(intake_ticket_id: original_intake.intake_ticket_id)
      session[:intake_id] = anonymous_intake.id
      session[:anonymous_session] = true
    end
  end
end
