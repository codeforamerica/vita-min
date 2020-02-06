module Questions
  class AdditionalDocumentsController < DocumentUploadQuestionController

    private

    def document_type
      "Other"
    end
  end
end
