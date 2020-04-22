module Documents
  class SelfieInstructionsController < DocumentUploadQuestionController
    layout "application"

    def self.document_type
      nil
    end
  end
end
