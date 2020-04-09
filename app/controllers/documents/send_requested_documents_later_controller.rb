module Documents
  class SendRequestedDocumentsLaterController < DocumentUploadQuestionController
    skip_before_action :require_sign_in
    after_action :clear_anonymous_session

    def edit
      original_intake = find_original_intake
      original_intake.documents << current_intake.documents
      SendRequestedDocumentsToZendeskJob.perform_later(original_intake.id)
      flash[:notice] = "Thank you, your documents have been submitted."
      redirect_to root_path
    end

    def self.show?(_)
      false
    end

    def self.form_class
      NullForm
    end

    private

    def clear_anonymous_session
      if session[:anonymous_session]
        intake = Intake.anonymous.find_by(id: session[:intake_id])
        intake.destroy if intake
        session[:anonymous_session] = false
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

