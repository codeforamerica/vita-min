module Documents
  class SelfieInstructionsController < DocumentUploadQuestionController
    layout "intake"

    def self.document_type
      nil
    end
  end
end
