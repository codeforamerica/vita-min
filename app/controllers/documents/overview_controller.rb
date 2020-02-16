module Documents
  class OverviewController < Questions::QuestionsController
    layout "application"

    helper_method :recommended_document_types

    def edit
      @documents = current_intake.documents
    end

    private

    def section_title
      "Documents"
    end

    def recommended_document_types
      DocumentNavigation.new(self).types_for_intake(current_intake)
    end
  end
end
