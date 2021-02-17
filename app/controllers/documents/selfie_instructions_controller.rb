module Documents
  class SelfieInstructionsController < DocumentUploadQuestionController
    layout "question"

    def illustration_path;end

    def self.document_type
      nil
    end
  end
end
