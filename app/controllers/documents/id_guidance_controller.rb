module Documents
  class IdGuidanceController < DocumentUploadQuestionController
    layout "intake"

    def edit; end

    def self.document_type
      nil
    end

    def illustration_path
      "id-guidance.svg"
    end

    def next_path
      next_step = DocumentNavigation.first_for_intake(current_intake)
      document_path(next_step.to_param)
    end
  end
end
