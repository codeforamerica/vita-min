module Documents
  class IntroController < DocumentUploadQuestionController
    layout "application"

    helper_method :recommended_document_types

    def edit; end

    def self.document_type
      nil
    end

    private

    def recommended_document_types
      DocumentNavigation.document_types_for_intake(current_intake)
    end
  end
end
