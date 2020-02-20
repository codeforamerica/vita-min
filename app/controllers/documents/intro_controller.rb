module Documents
  class IntroController < Questions::QuestionsController
    layout "application"

    helper_method :recommended_document_types

    def edit; end

    def next_path
      next_step = DocumentNavigation.new(self).first_for_intake(current_intake)
      document_path(next_step.to_param)
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
