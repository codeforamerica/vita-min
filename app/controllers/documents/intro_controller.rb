module Documents
  class IntroController < DocumentUploadQuestionController
    layout "application"

    helper_method :recommended_document_types

    def edit; end

    private

    def recommended_document_types
      DocumentNavigation.new(self).types_for_intake(current_intake)
    end
  end
end
