module Documents
  class SendRequestedDocumentsController < DocumentUploadQuestionController
    def edit
      SendRequestedDocumentsToZendeskJob.perform_later(intake: current_intake)
      flash[:notice] = "Thank you, your documents have been submitted."
      redirect_to root_path
    end

    def self.show?
      false
    end

    def self.form_class
      NullForm
    end
  end
end

