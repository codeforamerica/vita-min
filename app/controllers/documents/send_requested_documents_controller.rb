module Documents
  class SendRequestedDocumentsController < DocumentUploadQuestionController
    def edit
      SendRequestedDocumentsToZendeskJob.perform_later(current_intake.id)
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

