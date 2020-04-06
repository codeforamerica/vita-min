module Documents
  class OverviewController < Questions::QuestionsController
    layout "application"

    helper_method :recommended_document_types

    def edit
      @documents = current_intake.documents
    end

    private

    def recommended_document_types
      document_types = DocumentNavigation.new(self).types_for_intake(current_intake)
      include_requested_documents = @documents.where(document_type: "Requested").exists?
      document_types += ["Requested"] if include_requested_documents
      document_types
    end
  end
end
