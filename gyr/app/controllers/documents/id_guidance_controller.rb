module Documents
  class IdGuidanceController < DocumentUploadQuestionController
    layout "intake"

    def self.show?(intake)
      !ReturningClientExperimentService.new(intake).skip_identity_documents?
    end

    def edit; end

    def self.document_type
      nil
    end

    def illustration_path
      "id-guidance.svg"
    end
  end
end
