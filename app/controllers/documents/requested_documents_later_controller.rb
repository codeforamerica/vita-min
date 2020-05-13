module Documents
  class RequestedDocumentsLaterController < DocumentUploadQuestionController
    before_action :handle_session, only: :edit
    before_action :current_intake_or_home, only: :update
    skip_before_action :require_ticket

    def self.show?(_)
      false
    end

    def next_path(params = {})
      send_requested_documents_later_documents_path
    end

    def not_found
      render layout: "application"
    end

    def self.document_type
      "Requested Later"
    end

    private

    def current_intake_or_home
      if session[:intake_id].nil?
        redirect_to root_path
      end
    end

    def handle_session
      check_token_and_create_anonymous_session unless session_in_progress?
    end

    def check_token_and_create_anonymous_session
      original_intake = Intake.find_for_requested_docs_token(params[:token])
      if original_intake.present?
        create_anonymous_intake_session(original_intake)
      else
        redirect_to documents_requested_docs_not_found_path
      end
    end

    def create_anonymous_intake_session(original_intake)
      anonymous_intake = Intake.create_anonymous_intake(original_intake)
      session[:intake_id] = anonymous_intake.id
      session[:anonymous_session] = true
    end

    def anonymous_session_in_progress?
      session[:anonymous_session] && session[:intake_id].present?
    end

    def session_in_progress?
      current_user.present? || anonymous_session_in_progress?
    end
  end
end
