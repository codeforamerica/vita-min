module Documents
  class SelfieInstructionsController < DocumentUploadQuestionController
    layout "intake"

    def self.show?(intake)
      !ReturningClientExperimentService.new(intake).skip_identity_documents?
    end

    def self.document_type
      nil
    end
  end
end
